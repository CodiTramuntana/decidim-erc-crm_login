# frozen_string_literal: true

require_dependency 'decidim/force_authentication'

# Makes a decorator of ForceAuthentication to redirect to the
# new_user_crm_session_path

::Decidim::ForceAuthentication.class_eval do
  alias_method :original_ensure_authenticated!, :ensure_authenticated!

  private

  # redirect_to custom path
  def ensure_authenticated!
    return true unless current_organization.force_users_to_authenticate_before_access_organization

    unless user_signed_in?
      flash[:warning] = t("actions.login_before_access", scope: "decidim.core")
      return redirect_to decidim_erc_crm_login.new_crm_session_path
    end
  end

  # add path that should be allowed even if the user is not yet
  # authorized
  def allow_unauthorized_path?
    return true if %r{^\/crm_session}.match?(request.path) || %r{^\/locale}.match?(request.path) || %r{^\/cookies}.match?(request.path)
    false
  end
end
