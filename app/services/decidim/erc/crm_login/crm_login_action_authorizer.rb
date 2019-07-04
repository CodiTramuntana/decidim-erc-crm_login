# frozen_string_literal: true
module Decidim
  module Erc
    module CrmLogin
      class CrmLoginActionAuthorizer < Decidim::Verifications::DefaultActionAuthorizer
        attr_reader :allowed_membership_type_codes

		    # Overrides the parent class method, but it still uses it to keep the base behavior
		    def authorize
		      # Remove the additional setting from the options hash to avoid to be considered missing.
		      @allowed_membership_type_codes ||= options.delete("allowed_membership_type_codes")

		      status_code, data = *super

          if allowed_membership_type_codes.present?
		        # Does not authorize users with different postal codes
		        if status_code == :ok && !allowed_membership_type_codes.member?(authorization.metadata["membership_type_id"])
		          status_code = :unauthorized
		          data[:fields] = { "membership_type_id" => authorization.metadata["membership_type_id"] }
		        end

		        # Adds an extra message for inform the user the additional restriction for this authorization
		        data[:extra_explanation] = { key: "extra_explanation",
		                                     params: { scope: "decidim.verifications.dummy_authorization",
		                                               count: allowed_membership_type_codes.count,
		                                               membership_type_ids: allowed_membership_type_codes.join(", ") } }
		      end

		      [status_code, data]
		    end

		    # Adds the list of allowed postal codes to the redirect URL, to allow forms to inform about it
		    def redirect_params
		      { "membership_type_ids" => allowed_membership_type_codes&.join("-") }
		    end
		  end
    end
  end
end
