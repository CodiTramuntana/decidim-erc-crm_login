# frozen_string_literal: true

require "decidim/erc/crm_authenticable/engine"
require "decidim/erc/crm_authenticable/workflow"

module Decidim
  module Erc
    module CrmAuthenticable
      SCOPE_CODES = { "custom_21" => "custom_21" }.freeze if Rails.env.test?

      autoload :Log, "decidim/erc/crm_authenticable/log"
    end
  end
end
