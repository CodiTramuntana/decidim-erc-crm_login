# frozen_string_literal: true

module Decidim
  module Erc
    module CrmLogin
      class CrmLoginRegistrationService

        def initialize(document_number)
          @document_number = document_number
        end

        # Performs the WS request, which has two methods: login and doOperationTAO.
        #
        # The login method returns a token which is needed to invoke doOperationTAO.
        # In the doOperationTAO method we make the getHabitanteByDNI request.
        #
        # Returns a Hash with the following key => values.
        #   body   => WS response body, as Nokogiri::XML instance
        #   status => WS response status, as Integer
        def perform_request
          
          # response = retrieve_member_by_dni_response(perform_member_by_dni_request)
          response = retrieve_member_by_dni_response(temporary_response)
          
          {
            status: "response.status",
            body: response
          }

        rescue StandardError => e
          Rails.logger.error "[#{self.class.name}] Failed to perform request"
          Rails.logger.error e.message
          Rails.logger.error e.backtrace.join("\n")
          {} # To avoid crashing in SantBoiCensusAuthorizationHandler::ws_request_must_succeed
        end

        private

        attr_reader :document_number

        def perform_member_by_dni_request
          # DNI = custom_4, està guardat al camp custom_4 del CRM

          CiviCrm::Contact.find_by(custom_4:  @document_number)
        end

        def retrieve_member_by_dni_response(string)
          Nokogiri::XML(string).remove_namespaces!.xpath("//ResultSet//Result")
        end
        
        # def temporary_response
        #   nil
        # end

        def temporary_response
          @temporary_response ||= <<~XML
            <?xml version="1.0"?>
              <ResultSet xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
                <Result>
                  <contact_id>1</contact_id>
                  <contact_type>Individual</contact_type>
                  <sort_name>Doe, John</sort_name>
                  <display_name>John G Doe</display_name>
                  <do_not_email>0</do_not_email>
                  <do_not_phone>0</do_not_phone>
                  <do_not_mail>0</do_not_mail>
                  <do_not_trade>0</do_not_trade>
                  <is_opt_out>0</is_opt_out>
                  <home_URL>[http://www.example.com]</home_URL>
                  <preferred_mail_format>Both</preferred_mail_format>
                  <first_name>John</first_name>
                  <middle_name>G</middle_name>
                  <last_name>Doe</last_name>
                  <is_deceased>0</is_deceased>
                  <email_id>2</email_id>
                  <email>jdoe2@example.com</email>
                  <on_hold>0</on_hold>
                </Result>
              </ResultSet>
            XML
        end
      end
    end
  end
end