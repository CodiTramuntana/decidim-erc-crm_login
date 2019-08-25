# frozen_string_literal: true

require "rest-client"

module Decidim
  module Erc
    module CrmAuthenticable
      # This class holds the logic to connect to CiviCRM.
      class CiviCrmClient
        USER_DATA = %w(display_name email phone custom_21).freeze

        def initialize
          @credentials = Rails.application.secrets.erc_crm_authenticable
        end

        def find_militant(document_number)
          sanitize_response(
            perform_request(militant_json_params(document_number))
          )
        end

        def find_all_comarcals
          sanitize_response(
            perform_request(comarcals_json_params)
          )
        end

        def find_local_comarcal_relationships
          sanitize_response(
            perform_request(locals_json_params)
          )
        end

        private

        attr_reader :credentials

        # Returns a RestClient::Response
        def perform_request(json)
          RestClient.get(credentials[:api_base] + params(json))
        rescue StandardError => e
          Log.log.error("[#{self.class.name}]")
          Log.log_error(e)
        end

        # Returns a Hash
        def sanitize_response(response)
          return { is_error: true } unless response.is_a?(RestClient::Response)

          hsh = JSON.parse(response)
          {
            is_error: hsh["is_error"].positive? ? true : false,
            body: hsh["values"]
          }
        end

        # Returns a String
        def params(json)
          {
            entity: "Contact",
            action: "get",
            api_key: credentials[:api_key],
            key: credentials[:site_key],
            json: json
          }.map { |k, v| "#{k}=#{v}" }.join("&")
        end

        # Returns a String
        def militant_json_params(document_number)
          {
            sequential: 1,
            return: USER_DATA.join(","),
            custom_4: document_number,
            'api.Membership.get': {
              only_active: "yes",
              status_id: "New"
            }
          }.to_json
        end

        # Returns a String
        def local_comarcal_relationships_json_params
          {
            sequential: 1,
            options: { limit: 0 },
            contact_type: "Organization",
            contact_sub_type: "Local",
            return: "contact_id",
            'api.Relationship.get': {
              contact_id_a: "$value.contact_id",
              return: "contact_id_b"
            }
          }.to_json
        end

        # Returns a String
        def comarcals_json_params
          {
            sequential: 1,
            options: { limit: 0 },
            contact_type: "Organization",
            contact_sub_type: "Comarcal",
            return: "contact_id,display_name",
          }.to_json
        end
      end
    end
  end
end
