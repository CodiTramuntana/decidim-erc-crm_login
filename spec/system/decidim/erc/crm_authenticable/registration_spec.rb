# frozen_string_literal: true

require "spec_helper"

describe "Registration", type: :system do
  let(:organization) { create(:organization, force_users_to_authenticate_before_access_organization: true) }
  let!(:scope) { create(:scope, organization: organization, code: "custom_21") }

  before do
    switch_to_host(organization.host)
  end

  context "when the user signs up" do
    before do
      visit decidim.new_user_registration_path
    end

    it "is shown the 'Verify your identity document' page" do
      expect(page).to have_css("h1", text: "Verify your identity document")
      within "#register-form-step-1" do
        expect(page).to have_field("user_document_number")
      end
      expect(page).to have_button("Request verification")
    end

    context "when the 'Identity document form' is filled with valid data" do
      before do
        stub_valid_request
        within "#register-form-step-1" do
          fill_in :user_document_number, with: "123456789A"
        end
        click_button "Request verification"
      end

      it "redirects to the 'Registration' page" do
        expect(page).to have_css("h1", text: "Sign up")
        expect(page).to have_button("Sign up")
      end

      it "prefilles the 'Registration form' with data from CiviCRM" do
        within "#register-form" do
          expect(page).to have_field("user_name", with: "John Doe")
          expect(page).to have_field("user_nickname", with: "john_doe")
          expect(page).to have_field("user_email", with: "john.doe@example.org")
          expect(page).to have_field("user_phone_number", with: "666-666-666")
          expect(page).to have_field("user_password", with: "")
          expect(page).to have_field("user_password_confirmation", with: "")
        end
      end

      context "when the 'Registration form' is filled with valid data" do
        before do
          within "#register-form" do
            fill_in :user_password, with: "rPYWYKQJrXm97b4ytswc"
            fill_in :user_password_confirmation, with: "rPYWYKQJrXm97b4ytswc"
            check :user_tos_agreement
            check :user_newsletter
          end
          click_button "Sign up"
        end

        it "registers the user" do
          expect(page).to have_css(".callout.warning", text: "Please, login with your account before access")
        end
      end
    end

    context "when the 'Identity document form' is filled with used data" do
      let!(:user) do
        create(
          :user,
          organization: organization,
          scope: scope,
          extended_data: { document_number: Base64.encode64("123456789A") }
        )
      end

      before do
        stub_valid_request
        within "#register-form-step-1" do
          fill_in :user_document_number, with: "123456789A"
        end
        click_button "Request verification"
      end

      it "does NOT redirect to the decidim 'Registration' page" do
        expect(page).not_to have_css("h1", text: "Sign up")
        within "label[for='user_document_number']" do
          expect(page).to have_css(".form-error", text: "There is already a user registered with this data.")
        end
      end
    end

    context "when the 'Identity document form' is filled with invalid data" do
      context "and the document number is in wrong format" do
        before do
          stub_invalid_request_not_member
          within "#register-form-step-1" do
            fill_in :user_document_number, with: "(╯°□°）╯︵ ┻━┻"
          end
          click_button "Request verification"
        end

        it "does NOT redirect to the 'Registration' page" do
          expect(page).not_to have_css("h1", text: "Sign up")
          within "label[for='user_document_number']" do
            expect(page).to have_css(".form-error", text: "must be all uppercase and contain only letters and/or numbers")
          end
        end
      end

      context "and the user is not a member of ERC" do
        before do
          stub_invalid_request_not_member
          within "#register-form-step-1" do
            fill_in :user_document_number, with: "123456789A"
          end
          click_button "Request verification"
        end

        it "does NOT redirect to the decidim 'Registration' page" do
          expect(page).not_to have_css("h1", text: "Sign up")
          within "label[for='user_document_number']" do
            expect(page).to have_css(".form-error", text: "does not correspond to any dues-paying member of Esquerra Republicana.")
          end
        end
      end

      context "and the user was a member of ERC" do
        before do
          stub_invalid_request_was_member
          within "#register-form-step-1" do
            fill_in :user_document_number, with: "123456789A"
          end
          click_button "Request verification"
        end

        it "does NOT redirect to the decidim 'Registration' page" do
          expect(page).not_to have_css("h1", text: "Sign up")
          within "label[for='user_document_number']" do
            expect(page).to have_css(".form-error", text: "does not correspond to any dues-paying member of Esquerra Republicana.")
          end
        end
      end

      context "and the user is not a paying member of ERC" do
        before do
          stub_invalid_request_not_paying
          within "#register-form-step-1" do
            fill_in :user_document_number, with: "123456789A"
          end
          click_button "Request verification"
        end

        xit "does NOT redirect to the decidim 'Registration' page" do
          expect(page).not_to have_css("h1", text: "Sign up")
          within "label[for='user_document_number']" do
            expect(page).to have_css(".form-error", text: "does not correspond to any dues-paying member of Esquerra Republicana.")
          end
        end
      end
    end

    context "when the 'Identity document form' fails to connect the CiviCRM" do
      before do
        stub_invalid_request_connection_error
        within "#register-form-step-1" do
          fill_in :user_document_number, with: "123456789A"
        end
        click_button "Request verification"
      end

      it "does NOT redirect to the decidim 'Registration' page" do
        expect(page).not_to have_css("h1", text: "Sign up")
        expect(page).to have_css(".callout.alert", text: "It was not possible to connect with CiviCRM. Please try again later.")
      end
    end
  end
end
