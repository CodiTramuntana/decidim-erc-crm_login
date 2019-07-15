module Decidim
  module Erc
    module CrmAuthenticable
    	module DataEncryptor
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
    	end
    end
  end
end