# frozen_string_literal: true

module Decidim
  module Devise
    # Custom Devise SessionsController to avoid namespace problems.
    class SessionsController < ::Devise::SessionsController 
      include Decidim::DeviseControllers

      before_action :check_sign_in_enabled, only: :create
      # before_action :check_user_membership, only: :create
      def create
        super
      end
      # def create
      #   # puts "1111111111111111111111111"
      #   # unless check_user_membership?
      #   #   redirect_to root_path
      #   #   return 
      #   # end
      #   # puts "2222222222222222222222222"
      #   #   puts "33333333333333333333333333333"

      #   #   raise
      #     self.resource = warden.authenticate!(auth_options)
      #     set_flash_message!(:notice, :signed_in)
      #     sign_in(resource_name, resource)
      #     yield resource if block_given?
      #     respond_with resource, location: after_sign_in_path_for(resource)
      
      # end

      def after_sign_in_path_for(user)
        if first_login_and_not_authorized?(user) && !user.admin? && !pending_redirect?(user)
          decidim_verifications.first_login_authorizations_path
        else
          super
        end
      end

      # Calling the `stored_location_for` method removes the key, so in order
      # to check if there's any pending redirect after login I need to call
      # this method and use the value to set a pending redirect. This is the
      # only way to do this without checking the session directly.
      def pending_redirect?(user)
        store_location_for(user, stored_location_for(user))
      end

      def first_login_and_not_authorized?(user)
        user.is_a?(User) && user.sign_in_count == 1 && current_organization.available_authorizations.any? && user.verifiable?
      end

      def after_sign_out_path_for(user)
        request.referer || super
      end

      private

      def check_sign_in_enabled
        redirect_to new_user_session_path unless current_organization.sign_in_enabled?
      end

      
    end
  end
end
