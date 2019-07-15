# frozen_string_literal: true

require_dependency 'decidim/user'
Decidim::User.class_eval do
  include Decidim::Erc::CrmAuthenticable::DataEncryptor

  def civicrm_contact_id
    extended_data["contact_id"]
  end

  def member_of_local_area
    extended_data["member_of"]
  end

  def user_phone
    extended_data["phone"]
  end

  def document_number
    decipherData(extended_data["document_number"])
  end

  # Estem sobreescrivint aquest mètode, 
  # per tal de comprovar que l'usuari segueix com militant d'ERC
  # Fem la petició al CRM, i segons el resultat que ens retorna. 
  def active_for_authentication?
    revoke_crm_authenticable_authorization!
    super && user_membership?
  end

  def user_membership?
    return true if admin?
    response = Decidim::Erc::CrmAuthenticable::CrmAuthenticableRegistrationService.new(contact_id: self&.civicrm_contact_id).perform_login_request
    (response[:is_error] == 0) && (!response[:body][:end_date].present?)
  end

  def inactive_message
    user_membership? ? super : :not_membership
  end

  def after_confirmation
    return unless available_crm_authenticable_authorization?
    Decidim::Authorization.create_or_update_from(handler)
  end

  def grant_authorization
    after_confirmation
  end

  private

  def available_crm_authenticable_authorization?
    organization.available_authorizations.member?(handler_name)
  end

  def handler_params
    @handler_params ||= { user: self, document_number: document_number }
  end

  def handler_name
    @handler_name ||= Decidim::Erc::CrmAuthenticable::CrmAuthenticableAuthorizationHandler.handler_name
  end

  def handler
    @handler ||= Decidim::AuthorizationHandler.handler_for(handler_name, handler_params)
  end

  def granted_crm_authenticable_authorization
    Decidim::Authorization.find_by(decidim_user_id: id, name: handler_name)
  end

  def revoke_crm_authenticable_authorization!
    return if user_membership?
    granted_crm_authenticable_authorization.destroy! if granted_crm_authenticable_authorization
  end
end
