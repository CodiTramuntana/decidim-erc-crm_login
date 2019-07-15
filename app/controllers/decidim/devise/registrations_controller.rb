# frozen_string_literal: true

module Decidim
  module Devise
    # This controller customizes the behaviour of Devise's
    # RegistrationsController so we can specify a custom layout.
    class RegistrationsController < ::Devise::RegistrationsController
      include FormFactory
      include Decidim::DeviseControllers
      include NeedsTosAccepted

      before_action :check_sign_up_enabled
      before_action :configure_permitted_parameters

      invisible_captcha

      def new
        @form = form(Decidim::Erc::CrmAuthenticable::RegistrationFormStepOneForm).from_params(
            user: {
              sign_up_as: "user"
            }
          )
      end
      
      def new_step_2
        @form = form(Decidim::Erc::CrmAuthenticable::RegistrationFormStepOneForm).from_params(params[:user])
        
        if @form.valid?
          @form = form(Decidim::Erc::CrmAuthenticable::RegistrationFormStepTwoForm).from_params(
            user: {
              sign_up_as: "user",
            }.merge(extra_params)
          )
          flash[:notice] =  "S'ha trobat l'usuari"
        else
          render :new
          flash[:alert] =  "No s'ha pogut processar la solicitud"
        end
      end

      def create
        @form = form(Decidim::Erc::CrmAuthenticable::RegistrationFormStepTwoForm).from_params(params[:user])
        
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
            render :new_step_2
          end
        end
      end

      protected

      def check_sign_up_enabled
        redirect_to new_user_session_path unless current_organization.sign_up_enabled?
      end

      def configure_permitted_parameters
        devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :tos_agreement])
      end

      # Called before resource.save
      def build_resource(hash = nil)
        super(hash)
        resource.organization = current_organization
      end

      def extra_params
        return unless @form.data.present?
        @form.data
      end
    end
  end
end
