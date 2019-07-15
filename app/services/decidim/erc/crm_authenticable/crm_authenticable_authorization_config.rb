module Decidim
  module Erc
    module CrmAuthenticable
      # This is a handler for Erc::CrmAuthenticable config values.
      class CrmAuthenticableAuthorizationConfig
        class << self
          def url
            Rails.application.secrets.erc_crm_authenticable[:api_base] 
          end

          def site_key
            Rails.application.secrets.erc_crm_authenticable[:site_key]
          end

          def api_key
            Rails.application.secrets.erc_crm_authenticable[:api_key]
          end
          
          def secret
            Rails.application.secrets.erc_crm_authenticable[:erc_crm_authenticable_secret]
          end
        end
      end
    end
  end
end
