module Decidim
  module Erc
    module CrmLogin
      # This is a handler for SitgesCensus config values.
      # By now it only search for secret ones, but in future it could
      # be filled by a config record
      class CrmLoginAuthorizationConfig
        class << self
          # secret value for Sitges Census to encrypt an unique_id
          def secret
            Rails.application.secrets.erc_crm_login[:erc_crm_login_secret]
          end
        end
      end
    end
  end
end