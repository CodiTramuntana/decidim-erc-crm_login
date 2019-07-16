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
            errors.add(:document_number, "Document number error" )
          else
            if @response[:count] == 0 # No existe ningun habitante con los datos introducidos.
              errors.add(:document_number, I18n.t("document_number_not_valid", scope: "errors.messages.sant_boi_census_authorization_handler"))
            else
              if @response[:body].present?
                self.data = parse_response(@response[:body])
              else
                raise
                errors.add(:document_number, "Document number error" )
              end
            end  
          end 
          
        end

        # # Validates the document against the Sant Boi WS.
        # def document_must_be_valid
        #   return if errors.any? || citizen_found?

        #   case error_code
        #   when "0037" # No existe ningun habitante con los datos introducidos.
        #     errors.add(:document_number, I18n.t("document_number_not_valid", scope: "errors.messages.sant_boi_census_authorization_handler"))
        #   else
        #     Rails.logger.info "[#{self.class.name}] Unexpected WS response\n#{@response[:body]}"
        #     errors.add(:base, I18n.t("unexpected_error", scope: "errors.messages.sant_boi_census_authorization_handler"))
        #   end
        # end

        
        def duplicates
          Decidim::User.where(organization: current_organization).where('extended_data @> ?', { document_number: cipherData(document_number) }.to_json)
        end

        def uniqueness
          return if duplicates.none?
          errors.add(:base, I18n.t("decidim.errors.messages.erc_census_authorization_handler.duplicate_user"))
        end

        # Validates citizen is over 16 years of age.
        # def citizen_must_be_over_16_years_of_age
        #   return if errors.any? || over_16_years_of_age?

        #   errors.add(:base, I18n.t("too_young", scope: "errors.messages.sant_boi_census_authorization_handler"))
        # end

        # Returns a Hash with the following key => values.
        #   body   => WS response body, as Nokogiri::XML instance
        #   status => WS response status, as Integer
        def perform_request
          Decidim::Erc::CrmAuthenticable::CrmAuthenticableRegistrationService.new(document_number).perform_register_request
        end

        # # Retrieves the error code.
        # #
        # # Returns a String.
        # def error_code
        #   @response[:body].xpath("//ERROR//CODE").text
        # end

        # Returns true or false
        # def over_16_years_of_age?
        #   date_string = @response[:body].xpath("//HABITANTE//DATOSPERSONALES//HABFECNAC").text
        #   date_of_birth = Date.parse(date_string)
        #   age = ((Time.zone.now - date_of_birth.to_datetime) / 1.year.seconds).floor
        #   age >= 16
        # end
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
            member_of_name: response_body['custom_21'],
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
