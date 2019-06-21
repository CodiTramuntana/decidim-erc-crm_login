# frozen_string_literal: true

module Decidim
  module Erc
  	module CrmLogin
	    # This controller customizes the behaviour of Login/Register
	    # to the CiviCrm of ERc.
	    class SessionsController < ::Devise::SessionsController
	      include FormFactory

	      invisible_captcha
	      include Decidim::DeviseControllers

	      def new
	        @form = form(Decidim::Erc::CrmLogin::RegistrationForm).from_params(
	        	user: {
	            sign_up_as: "user"
	          }
	        )
	      end

	      def create
	      	CiviCrm.api_base = "https://dmaster.demo.civicrm.org"
	      	CiviCrm.site_key = "dfdsxgdsx"
					CiviCrm.api_key = "Zwyximzw0a3aK7gGVgHSnQNL"
	      	raise
	        @form = form(RegistrationForm).from_params(params[:user])

	        CreateRegistration.call(@form) do
	          on(:ok) do |user|
	            if user.active_for_authentication?
	              set_flash_message! :notice, :signed_up
	              sign_up(:user, user)
	              respond_with user, location: after_sign_up_path_for(user)
	            else
	              set_flash_message! :notice, :"signed_up_but_#{user.inactive_message}"
	              expire_data_after_sign_in!
	              respond_with user, location: after_inactive_sign_up_path_for(user)
	            end
	          end

	          on(:invalid) do
	            render :new
	          end
	        end
	      end

	      protected

	      # def check_sign_up_enabled
	      #   redirect_to new_user_session_path unless current_organization.sign_up_enabled?
	      # end

	      # def configure_permitted_parameters
	      #   devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :tos_agreement])
	      # end

	      # # Called before resource.save
	      # def build_resource(hash = nil)
	      #   super(hash)
	      #   resource.organization = current_organization
	      # end
	    end
  	end
  end
end
