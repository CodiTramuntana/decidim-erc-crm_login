# frozen_string_literal: true

module Decidim
  # A form object used to handle user registrations
  module Erc
    module CrmLogin
      # A form object used to handle user registrations
      class RegistrationFormStepTwoForm < Form
        mimic :user

        attribute :name, String
        attribute :nickname, String
        attribute :email, String
        attribute :password, String
        attribute :password_confirmation, String
        attribute :newsletter, Boolean
        attribute :tos_agreement, Boolean
        attribute :phone, String
        attribute :militant_code, String
        attribute :member_of_name, String
        attribute :member_of_code, String
        attribute :contact_id, String

        validates :name, presence: true
        validates :nickname, presence: true, length: { maximum: Decidim::User.nickname_max_length }
        validates :email, presence: true, 'valid_email_2/email': { disposable: true }
        validates :password, confirmation: true
        validates :password, password: { name: :name, email: :email, username: :nickname }
        validates :password_confirmation, presence: true
        validates :tos_agreement, allow_nil: false, acceptance: true

        validate :email_unique_in_organization
        validate :nickname_unique_in_organization

        validates :phone, presence: true

        def newsletter_at
          return nil unless newsletter?
          Time.current
        end

        def member_of
          #Falta veure si ens enviaran el codi del member of, o l'haurem de crear.
          scope = Decidim::Scope.find_or_create_by(name: member_of_name, code: member_of_code, organization: current_organization)
          @member_of ||= scope&.id
        end

        private

        def email_unique_in_organization
          errors.add :email, :taken if User.find_by(email: email, organization: current_organization).present?
        end

        def nickname_unique_in_organization
          errors.add :nickname, :taken if User.find_by(nickname: nickname, organization: current_organization).present?
        end
      end
    end
  end
end
