Decidim::Verifications.register_workflow(:crm_login_authorization_handler) do |workflow|
  workflow.form = "Decidim::Erc::CrmLogin::CrmLoginAuthorizationHandler"
  workflow.engine = Decidim::Erc::CrmLogin::Engine

  workflow.options do |options|
    options.attribute :membership_type_id, type: :string, required: false
    # options.attribute :join_date, type: :string, required: false
  end

  workflow.action_authorizer = "Decidim::Erc::CrmLogin::CrmLoginActionAuthorizer"
end