# frozen_string_literal: true

module CMSScanner
  module Error
    # SAML Authentication Required Error
    class SAMLAuthenticationRequired < Standard
      def to_s
        'SAML authentication is required to access this resource.'\
          'Please ensure SAML authentication credentials are provided.'
      end
    end
  end
end
