# frozen_string_literal: true

# This decorator...
Decidim::CreateRegistration.class_eval do
  # Method overrided.
  #
  def call
    return broadcast(:invalid) if form.invalid?

    create_user

    broadcast(:ok, @user)
  rescue ActiveRecord::RecordInvalid => e
    Decidim::Erc::CrmAuthenticable::Log.log.error("[#{self.class.name}] #{e.message}\n#{form.extended_data}")
    broadcast(:invalid)
  end

  private

  # Method overrided.
  #
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
      extended_data: form.extended_data,
      scope: find_scope_by_code
    )
  end

  # Method added.
  #
  def find_scope_by_code
    form.current_organization.scopes.find_by(code: form.extended_data["member_of_code"])
  end
end
