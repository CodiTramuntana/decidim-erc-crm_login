# frozen_string_literal: true

require "digest"

module Decidim
  module Erc
    module CrmAuthenticable
      # A form object used to handle ID number validations against CiviCRM.
      class CrmAuthenticableAuthorizationHandler < Decidim::AuthorizationHandler
        VALID_MEMBERSHIP_STATUS_IDS = %(1 2)

        attribute :document_number, String

        validates :document_number,
                  format: { with: /\A[A-Z0-9]*\z/, message: I18n.t("errors.messages.uppercase_only_letters_numbers") },
                  presence: true

        validate :ws_request_must_succeed, :ws_response_must_return_valid_membership

        def unique_id
          Digest::SHA512.hexdigest(
            "#{document_number}-#{Rails.application.secrets.erc_crm_authenticable[:secret_key]}"
          )
        end

        # Injects the valid membership into the `metadata` field of the authorization.
        # This information will be used by CrmAuthenticableActionAuthorizer.
        def metadata
          super.merge(@membership || {})
        end

        # Allows to validate the document_number against the CiviCRM WS without a User.
        # See Decidim::Erc::CrmAuthenticable::IdentityDocumentForm#document_number_must_be_valid
        def document_valid?
          ws_request_must_succeed
          ws_response_must_return_valid_membership
          errors.empty?
        end

        attr_reader :response

        private

        # Validates the request succeeded. Does not proceed if document_number format is invalid.
        def ws_request_must_succeed
          return if errors.any?

          @response = CiviCrmClient.new.find_militant(document_number)

          errors.add(:base, I18n.t("connection_failed", scope: "crm_authenticable.errors")) if response[:error]
        end

        # Validates the document_number against CiviCRM. Does not proceed if the WS request fails.
        def ws_response_must_return_valid_membership
          return if errors.any?

          errors.add(:document_number, I18n.t("document_invalid", scope: "crm_authenticable.errors")) unless valid_membership?
        end

        # Searches the body of the response for a valid CiviCRM membership.
        def valid_membership?
          @membership = response
                        .dig(:body, 0, "api.Membership.get", "values")
                        &.find { |membership| membership["status_id"].in?(VALID_MEMBERSHIP_STATUS_IDS) }
        end
      end
    end
  end
end
