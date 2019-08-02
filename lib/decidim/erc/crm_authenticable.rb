# frozen_string_literal: true

require 'decidim/erc/crm_authenticable/engine'
require "decidim/erc/crm_authenticable/workflow"

module Decidim
  module Erc
    module CrmAuthenticable
      SCOPE_CODES = { "custom_21" => "custom_21" }

      autoload :CiviCrmClient, "decidim/erc/crm_authenticable/civi_crm_client"
      autoload :UserAuthorizer, "decidim/erc/crm_authenticable/user_authorizer"
      autoload :Log, "decidim/erc/crm_authenticable/log"
    end
  end
end
