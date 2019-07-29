# frozen_string_literal: true

require "digest"

module Decidim
  module Erc
    module CrmAuthenticable
      class CrmAuthenticableAuthorizationHandler < Decidim::AuthorizationHandler
        attribute :document_number, String

        validates :document_number,
                  format: { with: /\A[A-Z0-9]*\z/, message: I18n.t("errors.messages.uppercase_only_letters_numbers") },
                  presence: true

        validate :ws_request_must_succeed, :id_must_be_from_active_member

        def unique_id
          Digest::SHA512.hexdigest(
            "#{document_number}-#{Rails.application.secrets.erc_crm_authenticable[:secret_key]}"
          )
        end

        def metadata
          membership || {}
        end

        # Allows to validate the document_number against the CiviCRM WS without a User.
        # See Decidim::Erc::CrmAuthenticable::IdentityDocumentForm#document_number_must_be_valid
        def document_valid?
          ws_request_must_succeed
          id_must_be_from_active_member
          errors.empty?
        end

        private

        attr_reader :response, :membership

        # Validates the request status is: OK 200.
        def ws_request_must_succeed
          return if errors.any?

          @response = CiviCrmClient.new(document_number).get_militant

          errors.add(:base, I18n.t("connection_failed", scope: "crm_authenticable.errors")) if response[:is_error]
        end

        def id_must_be_from_active_member
          return if errors.any?

          errors.add(:document_number, I18n.t("document_invalid", scope: "crm_authenticable.errors")) unless active_membership?
        end

        def active_membership?
          @membership = response.dig(:body, "api.Membership.get", "values", 0) # Hi haura més d'una?
          membership.present? && membership["end_date"].blank? # && al corrent de pagament
        end
      end
    end
  end
end
