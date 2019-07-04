# frozen_string_literal: true

module Decidim
  # A form object used to handle user registrations
  module Erc
    module CrmLogin
      class RegistrationFormStepOneForm < Form
        mimic :user

        attribute :document_number, String
        attribute :data, Hash

        validates :document_number,
                  format: { with: /\A[A-Z0-9]*\z/, message: I18n.t("errors.messages.uppercase_only_letters_numbers") },
                  presence: true

        validate :ws_request_must_succeed
        
        private

        # Validates the request status is: OK 200.
        def ws_request_must_succeed
          return if errors.any?
          
          @response = perform_request
          
          if @response[:body].present?
            self.data = parse_response(@response[:body])
          else
            errors.add(:document_number, "Document number error" )
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

        # Validates citizen is over 16 years of age.
        # def citizen_must_be_over_16_years_of_age
        #   return if errors.any? || over_16_years_of_age?

        #   errors.add(:base, I18n.t("too_young", scope: "errors.messages.sant_boi_census_authorization_handler"))
        # end

        # Returns a Hash with the following key => values.
        #   body   => WS response body, as Nokogiri::XML instance
        #   status => WS response status, as Integer
        def perform_request
          Decidim::Erc::CrmLogin::CrmLoginRegistrationService.new(document_number).perform_register_request
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

        def parse_response(response_body)
          return if response_body.blank?

          {
            name: response_body.xpath("//display_name").text,
            nickname: response_body.xpath("//display_name").text.underscore.parameterize,
            email: response_body.xpath("//email").text,
            phone: response_body.xpath("//custom_96").text,
            member_of_name: response_body.xpath("//custom_21").text,
            member_of_code: response_body.xpath("//custom_code_21").text,
            militant_code: response_body.xpath("//custom_35").text,
            contact_id: response_body.xpath("//contact_id").text,
          }
        end
      end
    end
  end
end
