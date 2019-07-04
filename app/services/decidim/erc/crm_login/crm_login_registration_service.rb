# frozen_string_literal: true

module Decidim
  module Erc
    module CrmLogin
      class CrmLoginRegistrationService

        def initialize(document_number=nil, contact_id=nil)
          @document_number = document_number
          @contact_id = contact_id
        end

        # Performs the WS request, which has two methods: login and doOperationTAO.
        # Returns a Hash with the following key => values.
        #   body   => WS response body, as Nokogiri::XML instance
        #   status => WS response status, as Integer
        def perform_register_request
          # response = retrieve_member_by_dni_response(perform_member_by_dni_request)
          response = retrieve_member_by_dni_response(temporary_response)
          
          # de moment no sabem quin status disponible hi ha, quan poguem fer la crida real ho sabrem,  
          {
            status: "response.status",
            body: response
          }
        end

        def perform_login_request
          # response = check_if_user_is_membership_response(find_member_by_contact_id_request)
          response = check_if_user_is_membership_response(temporary_response)
          
          {
            status: true,
            body: response
          }

          #Realment necessito tota aquesta resposta?
        end

        private

        attr_reader :document_number, :contact_id

        def perform_member_by_dni_request
          # DNI = custom_4, està guardat al camp custom_4 del CRM
          # Realment els militants són Contactes de la BD que tenen una Afiliació de Militant Activa. 
          # Això vol dir que haureu de consultar contactes amb aquestat entitat (Membership) de tipus Militant en un estat actiu. 
          CiviCrm::Contact.find_by(custom_4:  @document_number)
          # La propia GEM CIVICRM fa el control d'errors.
        end

        def retrieve_member_by_dni_response(string)
          Nokogiri::XML(string).remove_namespaces!.xpath("//ResultSet//Result")
        end

        def find_member_by_contact_id_request
          # Hauria de retornar true o false, si segueix siguent militant
          # Si pot tornar la data de militant, millor
          # si es fals, s'ha d'eliminar la verificació existent, i no permetre entrar. 
          CiviCrm::Contact.find_by(contact_id:  @contact_id)
        end
        
        def check_if_user_is_membership_response(string)
          Nokogiri::XML(string).remove_namespaces!.xpath("//ResultSet//Result")
        end
        
        def temporary_response
          @temporary_response ||= <<~XML
            <?xml version="1.0"?>
              <ResultSet xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
                <Result>
                  <contact_id>1</contact_id>
                  <contact_type>Individual</contact_type>
                  <sort_name>Doe, John</sort_name>
                  <display_name>Isaac Massot 1</display_name>
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
                  <email_id>6</email_id>
                  <email>imassot1@example.com</email>
                  <on_hold>0</on_hold>
                  <custom_21>Àrea Local Bcn</custom_21>
                  <custom_code_21>00002</custom_code_21>
                  <custom_35>12345678</custom_35>
                  <custom_96>617529431</custom_96>
                </Result>
              </ResultSet>
            XML
        end
      end
    end
  end
end