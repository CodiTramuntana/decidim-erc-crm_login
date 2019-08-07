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
    self.extended_data = parsed_extended_data if extended_data.is_a?(String)
  end

  private

  # Method added.
  #
  def parsed_extended_data
    JSON.parse(extended_data.gsub("=>", ":")).try(:merge, "phone_number" => encoded_phone_number)
  rescue JSON::ParserError => e
    Decidim::Erc::CrmAuthenticable::Log.log.error("[#{self.class.name}] #{e.message}")
    extended_data
  end

  # Method added.
  #
  def encoded_phone_number
    Base64.encode64(phone_number || "")
  end
end
