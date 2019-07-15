# frozen_string_literal: true

module Decidim
  module Erc
    module CrmAuthenticable
      class CrmAuthenticableRegistrationService

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
          # response = retrieve_member_by_dni_response(temporary_response)
          response = temporary_response_find_by_dni

          # de moment no sabem quin status disponible hi ha, quan poguem fer la crida real ho sabrem,  
          # {
          #   status: "response.status",
          #   body: response
          # }
          {
            is_error: response[:is_error],
            body: response[:values][0]
          }
        end

        def perform_login_request
          # response = check_if_user_is_membership_response(find_member_by_contact_id_request)
          response = temporary_response_of_user_is_membership
          # response = temporary_response_of_user_is_not_membership 
          {
            is_error: response[:is_error],
            body: response[:values][0]
          }

          #Realment necessito tota aquesta resposta?
        end

        def perform_verification_request
          # response = check_if_user_is_membership_response(find_member_by_contact_id_and_document_number_request)
          response = temporary_response_of_user_is_membership
          {
            is_error: response[:is_error],
            body: response[:values][0]
          }

          #Realment necessito tota aquesta resposta?
        end
        
        private

        attr_reader :document_number, :contact_id

        # Registre
        def perform_member_by_dni_request
          # DNI = custom_4, està guardat al camp custom_4 del CRM
          # Realment els militants són Contactes de la BD que tenen una Afiliació de Militant Activa. 
          # Això vol dir que haureu de consultar contactes amb aquestat entitat (Membership) de tipus Militant en un estat actiu. 
          CiviCrm::Contact.find_by(custom_4:  @document_number)
          # La propia GEM CIVICRM fa el control d'errors.
        end

        # Registre
        def retrieve_member_by_dni_response(string)
          Nokogiri::XML(string).remove_namespaces!.xpath("//ResultSet//Result")
        end

        def find_member_by_contact_id_request
          CiviCrm::Membership.find_by(active_only: true, contact_id:  @contact_id)
        end
        
        # Comprovar que l'usuari quan es verifica, té la informació correcte. 
        def find_member_by_contact_id_and_document_number_request
          # Hauria de retornar true o false, si segueix siguent militant
          # Si pot tornar la data de militant, millor
          # si es fals, s'ha d'eliminar la verificació existent, i no permetre entrar. 
          # s'Ha de fer una join, però fins que no tinguem l'accés..
          CiviCrm::Contact.find_by(custom_4:  @document_number)
          CiviCrm::Membership.find_by(active_only: true, contact_id:  @contact_id)
          # /sites/all/modules/civicrm/extern/rest.php?entity=Membership&action=get&api_key=userkey&key=sitekey&json={"sequential":1,"contact_id":22830,"active_only":1,"api.Contact.get":{"custom_4":"35032512Q"}}
        end
        
        # def temporary_response
        #   @temporary_response ||= <<~XML
        #     <?xml version="1.0"?>
        #       <ResultSet xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
        #         <Result>
        #           <contact_id>22830</contact_id>
        #           <contact_type>Individual</contact_type>
        #           <sort_name>Doe, John</sort_name>
        #           <display_name>Isaac Massot 3</display_name>
        #           <do_not_email>0</do_not_email>
        #           <do_not_phone>0</do_not_phone>
        #           <do_not_mail>0</do_not_mail>
        #           <do_not_trade>0</do_not_trade>
        #           <is_opt_out>0</is_opt_out>
        #           <home_URL>[http://www.example.com]</home_URL>
        #           <preferred_mail_format>Both</preferred_mail_format>
        #           <first_name>John</first_name>
        #           <middle_name>G</middle_name>
        #           <last_name>Doe</last_name>
        #           <is_deceased>0</is_deceased>
        #           <email_id>6</email_id>
        #           <email>imassot3@example.com</email>
        #           <on_hold>0</on_hold>
        #           <custom_21>Àrea Local Bcn</custom_21>
        #           <custom_code_21>00002</custom_code_21>
        #           <custom_35>12345678</custom_35>
        #           <custom_96>617529431</custom_96>
        #           <custom_4>000000X</custom_4>
        #         </Result>
        #       </ResultSet>
        #     XML
        # end

        def temporary_response_find_by_dni
          {
            "is_error": 0,
            "version": 3,
            "count": 1,
            "id": 22830,
            "values": [
              {
                "contact_id": "22830",
                "display_name": "Sílvia Lumeras i Medrano",
                "contact_is_deleted": "0",
                "email_id": "16132",
                "email": "silvia.lumeras@gmail.com",
                "civicrm_value_altres_dades_personals_1_id": "16999",
                "custom_4": "35032512Q",
                "civicrm_value_dades_administratives_3_id": "16999",
                "custom_21": "3966",
                "custom_35": "43026",
                "id": "22830"
              }
            ]
          }
        end

        def temporary_response_of_user_is_not_membership
          {
            "is_error": 0,
            "version": 3,
            "count": 25,
            "values": [
              {
                "contact_id": "1947",
                "membership_type_id": "1",
                "join_date": "1977-02-01",
                "start_date": "1977-02-01",
                "end_date": "2018-08-09",
                "status_id": "6",
                "is_override": "1",
                "is_test": "0",
                "is_pay_later": "0",
                "id": "10",
                "membership_name": "Militant",
                "relationship_name": "Child of",
                "api.Contact.get": {
                    "is_error": 0,
                    "version": 3,
                    "count": 0,
                    "values": [
                    ]
                }
              },
            ]
          }
        end

        def temporary_response_of_user_is_membership
          # {
          #   "is_error": 0,
          #   "version": 3,
          #   "count": 1,
          #   "id": 11935,
          #   "values": [
          #     {
          #       "contact_id": "17738",
          #       "membership_type_id": "3",
          #       "join_date": "2015-06-02",
          #       "start_date": "2015-06-02",
          #       "status_id": "2",
          #       "is_test": "0",
          #       "is_pay_later": "0",
          #       "id": "11935",
          #       "membership_name": "Amic/a",
          #       "relationship_name": "Child of"
          #     }
          #   ]
          # }
          {
            "is_error": 0,
            "version": 3,
            "count": 1,
            "id": 33160,
            "values": [
              {
                "contact_id": "22830",
                "membership_type_id": "1",
                "join_date": "2018-04-17",
                "start_date": "2018-04-17",
                "status_id": "1",
                "is_test": "0",
                "is_pay_later": "0",
                "id": "33160",
                "membership_name": "Militant",
                "relationship_name": "Child of"
              }
            ]
          }

          # {
          #     "is_error": 0,
          #     "version": 3,
          #     "count": 1,
          #     "id": 33160,
          #     "values": [
          #         {
          #             "contact_id": "22830",
          #             "membership_type_id": "1",
          #             "join_date": "2018-04-17",
          #             "start_date": "2018-04-17",
          #             "status_id": "1",
          #             "is_test": "0",
          #             "is_pay_later": "0",
          #             "id": "33160",
          #             "membership_name": "Militant",
          #             "relationship_name": "Child of",
          #             "api.Contact.get": {
          #                 "is_error": 0,
          #                 "version": 3,
          #                 "count": 1,
          #                 "id": 22830,
          #                 "values": [
          #                     {
          #                         "contact_id": "22830",
          #                         "contact_type": "Individual",
          #                         "contact_sub_type": [
          #                             "Militant"
          #                         ],
          #                         "sort_name": "Lumeras i Medrano, Sílvia",
          #                         "display_name": "Sílvia Lumeras i Medrano",
          #                         "do_not_email": "0",
          #                         "do_not_phone": "0",
          #                         "do_not_mail": "0",
          #                         "do_not_sms": "0",
          #                         "do_not_trade": "0",
          #                         "is_opt_out": "0",
          #                         "legal_identifier": "",
          #                         "external_identifier": "ML1043729",
          #                         "nick_name": "",
          #                         "legal_name": "",
          #                         "image_URL": "",
          #                         "preferred_communication_method": "",
          #                         "preferred_language": "ca_ES",
          #                         "preferred_mail_format": "Both",
          #                         "first_name": "Sílvia",
          #                         "middle_name": "",
          #                         "last_name": "Lumeras i Medrano",
          #                         "prefix_id": "",
          #                         "suffix_id": "",
          #                         "formal_title": "",
          #                         "communication_style_id": "",
          #                         "job_title": "",
          #                         "gender_id": "1",
          #                         "birth_date": "1961-06-25",
          #                         "is_deceased": "0",
          #                         "deceased_date": "",
          #                         "household_name": "",
          #                         "organization_name": "",
          #                         "sic_code": "",
          #                         "contact_is_deleted": "0",
          #                         "current_employer": "",
          #                         "address_id": "22428",
          #                         "street_address": "Av. Montserrat, 18 2n C",
          #                         "supplemental_address_1": "",
          #                         "supplemental_address_2": "",
          #                         "city": "SANT ESTEVE SESROVIRES        ",
          #                         "postal_code_suffix": "",
          #                         "postal_code": "08635",
          #                         "geo_code_1": "",
          #                         "geo_code_2": "",
          #                         "state_province_id": "",
          #                         "country_id": "",
          #                         "phone_id": "26592",
          #                         "phone_type_id": "1",
          #                         "phone": "937714060 - 666849169",
          #                         "email_id": "16132",
          #                         "email": "silvia.lumeras@gmail.com",
          #                         "on_hold": "0",
          #                         "im_id": "",
          #                         "provider_id": "",
          #                         "im": "",
          #                         "worldregion_id": "",
          #                         "world_region": "",
          #                         "civicrm_value_altres_dades_personals_1_id": "16999",
          #                         "custom_4": "35032512Q",
          #                         "individual_prefix": "",
          #                         "individual_suffix": "",
          #                         "communication_style": "",
          #                         "gender": "Dona",
          #                         "state_province_name": "",
          #                         "state_province": "",
          #                         "country": "",
          #                         "id": "22830"
          #                     }
          #                 ]
          #             }
          #         }
          #     ]
          # }
        end
      end
    end
  end
end