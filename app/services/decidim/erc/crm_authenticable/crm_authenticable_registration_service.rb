# frozen_string_literal: true
require 'rest-client'

module Decidim
  module Erc
    module CrmAuthenticable
      class CrmAuthenticableRegistrationService

        def initialize(document_number=nil, contact_id=nil)
          @document_number = document_number
          @contact_id = contact_id
        end

        # Performs the WS request
        # Returns a Hash with the following key => values.
        #   body   => WS response body,
        #   count  => WS response count,
        #   status => WS response status, as Integer
        def perform_register_request
          response = sanitize_response(perform_request(register_form_data_attributes.map{|k,v| "#{k}=#{v}"}.join('&')))
          
          {
            is_error: response['is_error'],
            count: response['count'],
            body: response['values'][0]
          }
        end

        def perform_login_request
          response = sanitize_response(perform_request(login_form_data_attributes.map{|k,v| "#{k}=#{v}"}.join('&')))
          
          {
            is_error: response['is_error'],
            count: response['count'],
            body: response['values'][0]
          }
        end

        def perform_verification_request
          response = sanitize_response(perform_request(verification_form_data_attributes.map{|k,v| "#{k}=#{v}"}.join('&')))
          
          {
            is_error: response['is_error'],
            count: response['count'],
            body: response['values'][0]
          }
        end
        
        private

        attr_reader :document_number, :contact_id

        # DNI = custom_4, està guardat al camp custom_4 del CRM
        # Realment els militants són Contactes de la BD que tenen una Afiliació de Militant Activa. 
        # Això vol dir que haureu de consultar contactes amb aquestat entitat (Membership) de tipus Militant en un estat actiu. 
        def register_form_data_attributes
          {
            entity: 'Contact',
            action: 'get',
            api_key: Decidim::Erc::CrmAuthenticable::CrmAuthenticableAuthorizationConfig.api_key,
            key: Decidim::Erc::CrmAuthenticable::CrmAuthenticableAuthorizationConfig.site_key, 
            json: {'sequential':1, 'custom_4': @document_number, 'api.Membership.get':{"only_active":"yes"}}.to_json
          }
        end

        # Comprovem si segueix siguent Membre actiu
        def login_form_data_attributes
          {
            entity: 'Membership',
            action: 'get',
            api_key: Decidim::Erc::CrmAuthenticable::CrmAuthenticableAuthorizationConfig.api_key,
            key: Decidim::Erc::CrmAuthenticable::CrmAuthenticableAuthorizationConfig.site_key, 
            json: {'sequential':1, 'active_only': true, 'contact_id': @contact_id }.to_json
          }
        end

        # Comprovar que l'usuari quan es verifica, té la informació correcte.
        # Hauria de retornar true o false, si segueix siguent militant
        # Si pot tornar la data de militant, millor
        # si es fals, s'ha d'eliminar la verificació existent, i no permetre entrar.  
        def verification_form_data_attributes
          {
            entity: 'Contact',
            action: 'get',
            api_key: Decidim::Erc::CrmAuthenticable::CrmAuthenticableAuthorizationConfig.api_key,
            key: Decidim::Erc::CrmAuthenticable::CrmAuthenticableAuthorizationConfig.site_key, 
            json: { 'sequential':1, 'custom_4': @document_number, 'api.Membership.get': {"active_only":true,"contact_id": @contact_id}}.to_json
          }
        end

        def perform_request params
          begin
            resp = RestClient.get( Decidim::Erc::CrmAuthenticable::CrmAuthenticableAuthorizationConfig.url + params )
          rescue RestClient::Unauthorized, RestClient::Forbidden => err
            puts 'Access denied'
            return err.response
          rescue RestClient::ImATeapot => err
            puts 'The server is a teapot! # RFC 2324'
            return err.response
          else
            puts 'It worked!'
            return resp
          end
        end

        def sanitize_response(string)
          return unless string
          JSON.parse(string)
        end
      end
    end
  end
end