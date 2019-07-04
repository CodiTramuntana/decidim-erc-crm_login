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
    super && check_user_membership?
  end

  def check_user_membership?
    check_if_still_membership = Decidim::Erc::CrmLogin::CrmLoginRegistrationService.new(contact_id: self&.civicrm_contact_id).perform_login_request
    check_if_still_membership[:status]
  end

  def inactive_message
    check_user_membership? ? super : :not_membership
  end
end
