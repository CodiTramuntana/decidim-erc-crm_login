# frozen_string_literal: true

module Decidim
  # A form object used to handle user registrations
  module Erc
    module CrmAuthenticable
      class RegistrationFormStepOneForm < Form
        include Decidim::Erc::CrmAuthenticable::DataEncryptor
        mimic :user

        attribute :document_number, String
        attribute :data, Hash

        validates :document_number,
                  format: { with: /\A[A-Z0-9]*\z/, message: I18n.t("errors.messages.uppercase_only_letters_numbers") },
                  presence: true

        validate :ws_request_must_succeed
        validate :uniqueness

        private

        # Validates the request status is: OK 200.
        def ws_request_must_succeed
          return if errors.any?
          
          @response = perform_request
          
          unless @response[:is_error] == 0
            errors.add(:document_number, I18n.t("document_number_not_valid", scope: "decidim.errors.messages.erc_census_authorization_handler"))
          else
            if @response[:count] == 0
              errors.add(:document_number, I18n.t("document_number_not_valid", scope: "decidim.errors.messages.erc_census_authorization_handler"))
            else
              if @response[:body].present?
                self.data = parse_response(@response[:body])
              else
                errors.add(:document_number, I18n.t("document_number_not_valid", scope: "decidim.errors.messages.erc_census_authorization_handler"))
              end
            end  
          end         
        end
        
        def duplicates
          Decidim::User.where(organization: current_organization).where('extended_data @> ?', { document_number: cipherData(document_number) }.to_json)
        end

        def uniqueness
          return if duplicates.none?
          errors.add(:document_number, I18n.t("decidim.errors.messages.erc_census_authorization_handler.duplicate_user"))
        end

        # Returns a Hash with the following key => values.
        #   body   => WS response body
        #   status => WS response status, as Integer
        def perform_request
          Decidim::Erc::CrmAuthenticable::CrmAuthenticableRegistrationService.new(document_number).perform_register_request
        end

        def response_valid?
          @response['is_error'] == 0
        end

        def parse_response(response_body)
          return if response_body.blank?
          {
            name: response_body['display_name'],
            nickname: nickname(response_body),
            email: response_body['email'],
            phone: response_body['phone'],
            member_of_code: response_body['custom_21'],
            militant_code: response_body['custom_35'],
            contact_id: response_body['contact_id'],
            document_number: response_body['custom_4'],
          }
        end

        def nickname(response_body)
          return response_body['nickname'] if response_body['nickname'].present?
          
          UserBaseEntity.nicknamize(response_body['display_name'], organization: current_organization)
        end
      end
    end
  end
end
