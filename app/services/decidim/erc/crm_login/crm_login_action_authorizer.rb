# frozen_string_literal: true
module Decidim
  module Erc
    module CrmLogin
      class CrmLoginActionAuthorizer < Decidim::Verifications::DefaultActionAuthorizer
        protected

        def unmatched_fields
          @unmatched_fields ||= (valued_options_keys & authorization.metadata.to_h.keys).each_with_object({}) do |field, unmatched|
            if field == "join_date"
              required_value = options[field].respond_to?(:value) ? options[field].value : options[field]          
              join_date_before = (Date.today - required_value.to_i.months)
              unmatched[field] = join_date_before.strftime("%d/%m/%Y") unless Date.parse(authorization.metadata[field]) <= join_date_before
              unmatched
            else
              required_value = options[field].respond_to?(:value) ? options[field].value : options[field]
              unmatched[field] = required_value if authorization.metadata[field] != required_value
              unmatched
            end
          end
        end
		  end
    end
  end
end
