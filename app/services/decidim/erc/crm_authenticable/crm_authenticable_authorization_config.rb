module Decidim
  module Erc
    module CrmAuthenticable
      # This is a handler for SitgesCensus config values.
      # By now it only search for secret ones, but in future it could
      # be filled by a config record
      class CrmAuthenticableAuthorizationConfig
        class << self
          # secret value for Sitges Census to encrypt an unique_id
          def secret
            Rails.application.secrets.erc_crm_authenticable[:erc_crm_authenticable_secret]
          end
        end
      end
    end
  end
end
