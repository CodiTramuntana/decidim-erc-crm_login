# frozen_string_literal: true

require "rest-client"

module Decidim
  module Erc
    module CrmAuthenticable
      # This class holds the logic to connect to CiviCRM.
      class CiviCrmClient
        USER_DATA = %w(display_name email phone custom_21).freeze

        def initialize(document_number = "")
          @document_number = document_number
          @credentials = Rails.application.secrets.erc_crm_authenticable
        end

        def get_militant
          sanitize_response(perform_request)
        end

        private

        attr_reader :document_number, :credentials

        # Returns a RestClient::Response
        def perform_request
          RestClient.get(credentials[:api_base] + query)
        rescue StandardError => e
          Log.log.error("[#{self.class.name}]")
          Log.log_error(e)
        end

        # Els militants són Contactes de la BD que tenen una Afiliació de Militant Activa.
        # Consultar contactes amb Membership de tipus Militant en un estat actiu.
        # Returns a String
        def query
          {
            entity: "Contact",
            action: "get",
            api_key: credentials[:api_key],
            key: credentials[:site_key],
            json: {
              sequential: 1,
              return: USER_DATA.join(","),
              custom_4: document_number,
              'api.Membership.get': { only_active: "yes", status_id: "New" }
            }.to_json
          }.map { |k, v| "#{k}=#{v}" }.join("&")
        end

        # Returns a Hash
        def sanitize_response(response)
          return { is_error: true } unless response.is_a?(RestClient::Response)

          hsh = JSON.parse(response)
          {
            is_error: hsh["is_error"].positive? ? true : false,
            body: hsh["values"][0]
          }
        end
      end
    end
  end
end
