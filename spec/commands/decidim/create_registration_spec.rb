# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe CreateRegistration do
      describe "call" do
        let(:organization) { create(:organization) }
        let!(:scope) { create(:scope, organization: organization, code: scope_code) }
        let(:scope_code) { "custom_21" }
        let(:extended_data) { { "member_of_code" => "custom_21" } }
        let(:phone_number) { "666-666-666" }

        let(:form) do
          RegistrationForm.from_params(
            user: {
              name: "Username",
              nickname: "nickname",
              email: "user@example.org",
              password: "Y1fERVzL2F",
              password_confirmation: "Y1fERVzL2F",
              tos_agreement: "1",
              newsletter_at: "1",
              phone_number: phone_number,
              extended_data: extended_data.to_json
            }
          ).with_context(current_organization: organization)
        end
        let(:command) { described_class.new(form) }

        describe "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "creates a new user" do
            expect(User).to receive(:create!).with(
              name: form.name,
              nickname: form.nickname,
              email: form.email,
              password: form.password,
              password_confirmation: form.password_confirmation,
              tos_agreement: form.tos_agreement,
              newsletter_notifications_at: form.newsletter_at,
              email_on_notification: true,
              organization: organization,
              accepted_tos_version: organization.tos_version,
              extended_data: extended_data.merge("phone_number" => Base64.encode64(phone_number)),
              scope: scope
            ).and_call_original

            expect { command.call }.to change(User, :count).by(1)
          end
        end

        describe "when the command fails to find the scope by code" do
          let(:scope_code) { "different_code" }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end
        end
      end
    end
  end
end
