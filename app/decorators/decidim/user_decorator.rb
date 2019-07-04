# frozen_string_literal: true

require_dependency 'decidim/user'
Decidim::User.class_eval do

  def civicrm_contact_id
    extended_data["contact_id"]
  end

  def member_of_local_area
    extended_data["member_of"]
  end

  def user_phone
    extended_data["phone"]
  end

  # Estem sobreescrivint aquest mètode, 
  # per tal de comprovar que l'usuari segueix com militant d'ERC
  # Fem la petició al CRM, i segons el resultat que ens retorna. 
  def active_for_authentication?
    revoke_crm_login_authorization!
    super && user_membership?
  end

  def user_membership?
    return true if admin?
    response = Decidim::Erc::CrmLogin::CrmLoginRegistrationService.new(contact_id: self&.civicrm_contact_id).perform_login_request
    (response[:is_error] == 0) && (!response[:body][:end_date].present?)
  end

  def inactive_message
    user_membership? ? super : :not_membership
  end

  # def delete_authorization_if_not_membership
  #   # return if user_membership?
  #   Decidim::Authorization.where(decidim_user_id: self.id, name: "crm_login_authorization_handler").destroy_all
  # end


# ---------
  def after_confirmation
    return unless available_crm_login_authorization?
    Decidim::Authorization.create_or_update_from(handler)
  end

  def grant_authorization
    after_confirmation
  end

  # def email_changed?
  #   revoke_members_picker_authorization!
  # end

  private

  def available_crm_login_authorization?
    organization.available_authorizations.member?(handler_name)
  end

  def handler_params
    @handler_params ||= { user: self, contact_id: civicrm_contact_id }
  end

  def handler_name
    @handler_name ||= Decidim::Erc::CrmLogin::CrmLoginAuthorizationHandler.handler_name
  end

  def handler
    @handler ||= Decidim::AuthorizationHandler.handler_for(handler_name, handler_params)
  end

  def granted_crm_login_authorization
    Decidim::Authorization.find_by(decidim_user_id: id, name: handler_name)
  end

  def revoke_crm_login_authorization!
    return if user_membership?
    granted_crm_login_authorization.destroy! if granted_crm_login_authorization
  end


end
