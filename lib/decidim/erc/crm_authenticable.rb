# frozen_string_literal: true

require "decidim/erc/crm_authenticable/engine"
require "decidim/erc/crm_authenticable/workflow"

module Decidim
  module Erc
    module CrmAuthenticable
      # IDs to filter CiviCRM Contacts of type 'Organization' and sub_type 'Comarcal'
      # Used to generate the scopes mapping that is assigned to SCOPE_CODES.
      # See lib/tasks/civi_crm.rake
      # Must be set up via initializer.
      CIVICRM_COMARCAL_EXCEPTIONS = [].freeze
      # Used to assign the correct scope to the user based on CiviCRM data.
      # See app/decorators/decidim/create_registration_decorator.rb
      # Must be set up via initializer.
      SCOPE_CODES = {}.freeze
      # Used to validate the data returned by CiviCRM.
      # See app/services/decidim/erc/crm_authenticable/crm_authenticable_authorization_handler.rb
      # Must be set up via initializer.
      VALID_MBSP_STATUS_IDS = [].freeze
      VALID_MBSP_JOIN_DATE = Date.new

      autoload :Log, "decidim/erc/crm_authenticable/log"
    end
  end
end
