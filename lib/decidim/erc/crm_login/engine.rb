# frozen_string_literal: true

require 'rails'
require 'decidim/core'
require 'civicrm'

module Decidim
	module Core
		class Engine < ::Rails::Engine
			routes do
        devise_scope :user do
      	  post 'users/sign_up/new_step_2', controller: "devise/registrations", action: 'new_step_2', as: :registration_step_two
				end
      end
		end
	end
end

module Decidim
  module Erc
    module CrmLogin
      class Engine < ::Rails::Engine
        isolate_namespace Decidim::Erc::CrmLogin

        # make decorators autoload in development env
	      config.autoload_paths << File.join(
	        Decidim::Erc::CrmLogin::Engine.root, 'app', 'decorators', '{**}'
	      )
	    	
	    	# make decorators available to applications that use this Engine
	      config.to_prepare do
	        Dir.glob(Decidim::Erc::CrmLogin::Engine.root + 'app/decorators/**/*_decorator*.rb').each do |c|
	          require_dependency(c)
	        end
	      end
			end
    end
  end
end
