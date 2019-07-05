# frozen_string_literal: true

require_dependency 'decidim/create_registration'
Decidim::CreateRegistration.class_eval do
  include Decidim::Erc::CrmLogin::DataEncryptor

  private

  def create_user
    @user = Decidim::User.create!(
      email: form.email,
      name: form.name,
      nickname: form.nickname,
      password: form.password,
      password_confirmation: form.password_confirmation,
      organization: form.current_organization,
      tos_agreement: form.tos_agreement,
      newsletter_notifications_at: form.newsletter_at,
      email_on_notification: true,
      accepted_tos_version: form.current_organization.tos_version,
      extended_data: extended_data,
    )
  end

  def extended_data
    {
      phone: form.phone,
      militant_code: form.militant_code,
      member_of: form.member_of,
      contact_id: form.contact_id,
      document_number: cipherData(form.document_number)
    }
  end
end
