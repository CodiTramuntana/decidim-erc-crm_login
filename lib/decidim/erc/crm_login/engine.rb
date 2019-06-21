# frozen_string_literal: true

require 'rails'
require 'decidim/core'
require 'civicrm'

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

	      routes do
	      	devise_scope :user do
				    # get "/some/route" => "some_devise_controller"
	      		resource :crm_session, only: [:new, :create, :destroy], controller: "sessions"
				  end
	        # Add engine routes here
	        # resources :department_admin
	        # root to: "department_admin#index"
	      end

	    end

    end
  end
end
