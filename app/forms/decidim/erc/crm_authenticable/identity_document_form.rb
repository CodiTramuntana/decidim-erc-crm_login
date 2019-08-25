# frozen_string_literal: true

module Decidim
  module Erc
    module CrmAuthenticable
      # A form object used to validate ID numbers with CrmAuthenticableAuthorizationHandler.
      class IdentityDocumentForm < Form
        mimic :user

        attribute :document_number, String

        validates :document_number,
                  format: { with: /\A[A-Z0-9]*\z/, message: I18n.t("errors.messages.uppercase_only_letters_numbers") },
                  presence: true

        validate :document_number_must_be_valid, :document_number_must_be_unique

        def registration_form_params
          return {} if errors.any? || authorization_handler.response.nil?

          {
            name: user_data["display_name"],
            nickname: nickname,
            email: user_data["email"],
            phone_number: user_data["phone"],
            document_number: encoded_document_number,
            member_of_code: user_data["custom_21"]
          }
        end

        private

        def document_number_must_be_valid
          return if errors.any? || authorization_handler.document_valid?

          if authorization_handler.errors.keys.include?(:document_number)
            errors.add(:document_number, I18n.t("document_invalid", scope: "crm_authenticable.errors"))
          else
            errors.add(:base, I18n.t("connection_failed", scope: "crm_authenticable.errors"))
          end
        end

        def document_number_must_be_unique
          return if errors.any? || duplicates.none?

          errors.add(:document_number, I18n.t("duplicate_user", scope: "crm_authenticable.errors"))
        end

        def authorization_handler
          @authorization_handler ||= CrmAuthenticableAuthorizationHandler.from_params(document_number: document_number)
        end

        def duplicates
          Decidim::User
            .where(organization: current_organization)
            .where("extended_data @> ?", { document_number: encoded_document_number }.to_json)
        end

        def user_data
          @user_data ||= authorization_handler.response[:body][0].slice(*CiviCrmClient::USER_DATA)
        end

        def nickname
          UserBaseEntity.nicknamize(user_data["display_name"], organization: current_organization)
        end

        def encoded_document_number
          Base64.encode64(document_number)
        end
      end
    end
  end
end
