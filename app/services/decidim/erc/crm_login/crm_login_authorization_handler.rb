# frozen_string_literal: true
require "digest"

module Decidim
  module Erc
    module CrmLogin
      class CrmLoginAuthorizationHandler < Decidim::AuthorizationHandler

        attribute :document_number, String

        validates :document_number, presence: true
        validates :document_number, format: { with: /\A[A-z0-9]*\z/ }, presence: true
        
        validate :erc_crm_census_valid?

        def unique_id
        	Digest::SHA512.hexdigest(
            "#{document_number}-#{Decidim::Erc::CrmLogin::CrmLoginAuthorizationConfig.secret}"
          )
        end
       
        def metadata
        	{
            document_number: cipherData(sanitize_document_number),
            membership_type_id: sanitize_membership_type_id,
            membership_name: sanitize_membership_name,
            join_date: sanitize_join_date,
            start_date: sanitize_start_date,
            end_date: sanitize_end_date,
            status_id: sanitize_status_id,
          }
        end

        # Returns a boolean
        def erc_crm_census_valid?
        	return false if errors.any? || response.blank?
          
          unless success_response?
            errors.add(:base, I18n.t('errors.messages.salou_census_authorization_handler.not_valid'))
            errors.add(:base, I18n.t('errors.messages.salou_census_authorization_handler.cannot_validate'))
          end
          errors.empty?
        end

        private
      
        # Check for WS needed values
        #
        # Returns a boolean
        def uncomplete_credentials?
          sanitize_document_number.blank? #|| sanitize_birthdate.blank?
        end

        # Document number parameter, as String
        #
        # Returns a String
        def sanitize_document_number
          @sanitize_document_number ||= document_number&.to_s
        end

        # Prepares and perform WS request.
        # It rescue failed connections to SalouCensus
        #
        # Returns an stringified XML
        def response
        	return nil if uncomplete_credentials?
        	return @response if already_processed?

          rs = request_ws
          return nil unless rs

          @response ||= { body: rs[:body], is_error: rs[:is_error] }
        end

        def request_ws
        	raise
        	Decidim::Erc::CrmLogin::CrmLoginRegistrationService.new(document_number: sanitize_document_number, contact_id: user.civicrm_contact_id).perform_verification_request
        end

        # Creates a Base64 String from a String
        #
        # Return a String
        def cipherData(data)
          return '' unless data

          Base64.encode64(data)
        end

        # Creates a String from a Base64 String
        #
        # Return a String
        def decipherData(data)
          return '' unless data

          Base64.decode64(data)
        end

        def sanitize_response
        	return unless response
        	@sanitize_response ||= response[:body]
        end

        def sanitize_join_date
        	@sanitize_join_date ||= sanitize_response[:join_date]&.to_date&.strftime('%d/%m/%Y')
        end

        def sanitize_end_date
        	@sanitize_end_date ||= sanitize_response[:end_date]&.to_date&.strftime('%d/%m/%Y')
        end

        def sanitize_start_date
        	@sanitize_start_date ||= sanitize_response[:start_date]&.to_date&.strftime('%d/%m/%Y')
        end

        def sanitize_membership_type_id
        	@sanitize_membership_type_id ||= sanitize_response[:membership_type_id]
        end

        def sanitize_membership_name
        	@sanitize_membership_name ||= sanitize_response[:membership_name]
        end

        def sanitize_status_id
        	@sanitize_status_id ||= sanitize_response[:status_id]
        end
        
        # Check if request had benn already been processed and saved
        #
        # Returns a boolean
        def already_processed?
        	defined?(@response)
        end

        # Check if request had been correctly performed
        #
        # Returns a boolean
        def success_response?
        	# Status code 200, success request. Otherwise, error
          response[:is_error] == 0
        end
      end
		end
  end
end
