# frozen_string_literal: true

# This decorator...
Decidim::RegistrationForm.class_eval do
  # Attributes added.
  attribute :phone_number, String
  attribute :extended_data, String

  # Validation added.
  validates :extended_data, presence: true

  # Method added.
  #
  def before_validation
    self.extended_data = JSON.parse(extended_data).try(:merge, { phone_number: encoded_phone_number })
  rescue JSON::ParserError => e
    Decidim::Erc::CrmAuthenticable::Log.log.error("[#{self.class.name}] #{e.message}")
  end

  private

  # Method added.
  #
  def encoded_phone_number
    Base64.encode64(phone_number || "")
  end
end
