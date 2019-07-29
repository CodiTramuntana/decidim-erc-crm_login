# frozen_string_literal: true

module Decidim
  module Devise
    # Custom Devise SessionsController to avoid namespace problems.
    class SessionsController < ::Devise::SessionsController
      include Decidim::DeviseControllers

      before_action :check_sign_in_enabled, only: :create

      # Overwritting this method
      def create
        result = current_user&.crm_authorize!

        if (result.nil? || result[:authorized])
          super
        else
          sign_out
          flash[:alert] = result[:error]
          redirect_to new_user_session_path
        end
      end

      def after_sign_in_path_for(user)
        super
      end

      def pending_redirect?(user)
        store_location_for(user, stored_location_for(user))
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
