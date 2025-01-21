# frozen_string_literal: true

# This decorator adds the management of new form fields.
module Decidim::RegistrationFormDecorator
  def self.decorate
    Decidim::RegistrationForm.class_eval do
      # Attributes added.
      attribute :phone_number, String
      attribute :document_number, String
      attribute :member_of_code, String
  
      # Validation added.
      validates_presence_of :document_number, :member_of_code
  
      # Method added.
      # Returns a Hash with the new attributes; the phone_number encoded.
      def extended_data
        {
          phone_number: Base64.strict_encode64(phone_number || ""),
          document_number: document_number,
          member_of_code: member_of_code
        }
      end
    end
  end
end

::Decidim::RegistrationFormDecorator.decorate
