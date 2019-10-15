# frozen_string_literal: true

require "decidim/erc/crm_authenticable/engine"
require "decidim/erc/crm_authenticable/workflow"

module Decidim
  module Erc
    module CrmAuthenticable
      # Used to assign the correct scope to the user based on CiviCRM data.
      # See app/decorators/decidim/create_registration_decorator.rb
      # Must be set up via initializer.
      SCOPE_CODES = Hash.new
      # Used to validate the data returned by CiviCRM.
      # See app/services/decidim/erc/crm_authenticable/crm_authenticable_authorization_handler.rb
      # Must be set up via initializer.
      VALID_MBSP_STATUS_IDS = Array.new
      VALID_MBSP_JOIN_DATE = Date.new

      autoload :Log, "decidim/erc/crm_authenticable/log"
    end
  end
end
