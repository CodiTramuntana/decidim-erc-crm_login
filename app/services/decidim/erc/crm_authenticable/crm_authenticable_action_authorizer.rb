# frozen_string_literal: true

module Decidim
  module Erc
    module CrmAuthenticable
      # This class overrides the behaviour of DefaultActionAuthorizer.
      class CrmAuthenticableActionAuthorizer < Decidim::Verifications::DefaultActionAuthorizer
        protected

        # Method overrided
        # Handles the verification of the authorization option :join_field.
        # Converts the required value (membership seniority in number of months)
        # from Integer to Date and compares it to the metadata field value as Date.
        def unmatched_fields
          @unmatched_fields ||= (valued_options_keys & authorization.metadata.to_h.keys).each_with_object({}) do |field, unmatched|
            if field == "join_date"
              required_value = Date.parse(options["join_date"])
              authorization_value = Date.parse(authorization.metadata["join_date"])
              unmatched[field] = required_value.strftime("%d/%m/%Y") unless authorization_value <= required_value
            else
              required_value = options[field].respond_to?(:value) ? options[field].value : options[field]
              unmatched[field] = required_value if authorization.metadata[field] != required_value
            end
            unmatched
          end
        end
      end
    end
  end
end
