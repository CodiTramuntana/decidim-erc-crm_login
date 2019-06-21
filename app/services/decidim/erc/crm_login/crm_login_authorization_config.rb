# frozen_string_literal: true

module Decidim
  module Erc
    module CrmLogin
      # This is a handler for CrmLogin config values.
      class CrmLoginAuthorizationConfig
        class << self
          # Access URL for CrmLogin WS
          def url
            Rails.application.secrets.erc_crm_login[:erc_crm_login_url]
          end
        end
      end
    end
  end
end
