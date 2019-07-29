# frozen_string_literal: true

require "spec_helper"

describe "Action Authorization", type: :system do
  let(:handler_name) { "crm_authenticable_authorization_handler" }
  let(:organization) { create(:organization, available_authorizations: [handler_name]) }
  let(:scope) { create(:scope, organization: organization) }
  let(:participatory_space) { create(:participatory_process, :with_steps, organization: organization) }
  let(:active_step_id) { participatory_space.active_step.id }
  let(:component) do
    create(
      :surveys_component,
      participatory_space: participatory_space,
      permissions: permissions,
      step_settings: { active_step_id => { allow_answers: true } }
    )
  end
  let!(:survey) { create(:survey, component: component) }
  let!(:question) { create(:questionnaire_question, questionnaire: survey.questionnaire, position: 0) }
  let(:user) { create :user, :confirmed, scope: scope, organization: organization }
  let!(:authorization) {  create(:authorization, name: handler_name, user: user, metadata: metadata) }
  let(:metadata) { { membership_type_id: "1", join_date: join_date } }
  let(:join_date) { "" }

  def answer_survey
    within "#edit_questionnaire_#{survey.id}" do
      fill_in :questionnaire_answers_0, with: "NS/NC"
      check :questionnaire_tos_agreement
      click_button "Submit"
    end
    page.driver.browser.switch_to.alert.accept
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when visiting a component to perform some action" do
    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit main_component_path(component)
    end

    context "and the component action is NOT authorized " do
      let(:permissions) { nil }

      it "allows to execute the action" do
        answer_survey
        expect(page).to have_css(".callout.success", text: "Survey successfully answered.")
      end
    end

    context "and the component action is authorized with custom action authorizer options" do
      let(:required_join_date) { 3 }
      let(:permissions) do
        {
          answer: {
            authorization_handlers: {
              handler_name => {
                options: { membership_type_id: "1", join_date: required_join_date }
              }
            }
          }
        }
      end

      context "when the authorization metadata is missing required fields" do
        let(:metadata) { { membership_type_id: "1" } }

        it "prompts user to reauthorize" do
          expect(page).to have_content("Authorization required")
          expect(page).to have_content("we need you to reauthorize because we lack the following data:")
          expect(page).to have_content("Membership seniority. (number of months)")
        end
      end

      context "when the authorization metadata is invalid" do
        let(:join_date) { (required_join_date - 1).months.ago }

        it "does NOT authorize the user" do
          expect(page).to have_content("Not authorized")
          expect(page).to have_content("Sorry, you can't perform this action as some of your authorization data doesn't match.")
          expect(page).to have_content("Membership seniority. (number of months) value (#{required_join_date.months.ago.strftime("%d/%m/%Y")}) isn't valid.")
        end
      end

      context "when the authorization metadata is valid" do
        let(:join_date) { (required_join_date + 1).months.ago }

        it "authorizes the user" do
          answer_survey
          expect(page).to have_css(".callout.success", text: "Survey successfully answered.")
        end
      end
    end
  end
end
