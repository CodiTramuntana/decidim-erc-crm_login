# frozen_string_literal: true

require "decidim/erc/crm_authenticable/engine"
require "decidim/erc/crm_authenticable/workflow"

module Decidim
  module Erc
    module CrmAuthenticable
      # Names to filter CiviCRM Contacts of type 'Organization' and sub_type 'Comarcal'
      # Used to generate the scopes mapping that is assigned to SCOPE_CODES.
      # See lib/tasks/civi_crm.rake
      # Must be set up via initializer.
      CIVICRM_COMARCAL_EXCEPTIONS = Array.new
      SCOPE_CODES = { "custom_21" => "custom_21" }.freeze if Rails.env.test?

      autoload :Log, "decidim/erc/crm_authenticable/log"
    end
  end
end
