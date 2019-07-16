# frozen_string_literal: true

module Decidim
  # A form object used to handle user registrations
  module Erc
    module CrmAuthenticable
      # A form object used to handle user registrations
      class RegistrationFormStepTwoForm < Form
        include Decidim::TranslatableAttributes
        include Decidim::TranslationsHelper

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
        attribute :member_of_code, String
        attribute :contact_id, String
        attribute :document_number, String

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
          @response = perform_request_local_section

          return unless @response[:is_error] == 0
          scope = Decidim::Scope.find_or_create_by(name: i18n_name(@response[:body]["display_name"]), code: @response[:body]["contact_id"], organization: current_organization)
          @member_of ||= scope&.id
        end

        private

        def perform_request_local_section
          Decidim::Erc::CrmAuthenticable::CrmAuthenticableRegistrationService.new(nil, member_of_code).perform_local_section_request
        end

        def email_unique_in_organization
          errors.add :email, :taken if User.find_by(email: email, organization: current_organization).present?
        end

        def nickname_unique_in_organization
          errors.add :nickname, :taken if User.find_by(nickname: nickname, organization: current_organization).present?
        end

        def i18n_name scope_name
          current_organization.available_locales.inject({}) do |names, locale|
            names.update(locale.to_sym => scope_name)
          end
        end
      end
    end
  end
end
