# frozen_string_literal: true

module Decidim
  module Erc
    module CrmAuthenticable
      class CrmAuthenticableActionAuthorizer < Decidim::Verifications::DefaultActionAuthorizer
        protected

        # Estem sobreescrivint aquest mètode per tal de poder fer la comprovació correctament amb la data de militància
        # ja que ha de ser igual superior a la marcada als permisos.
        def unmatched_fields
          @unmatched_fields ||= (valued_options_keys & authorization.metadata.to_h.keys).each_with_object({}) do |field, unmatched|
            if field == "join_date"
              required_value = (Date.current - options[field].to_i.months)
              authorization_value = Date.parse(authorization.metadata[field])
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
