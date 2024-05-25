# frozen_string_literal: true

module CMSScanner
  module Error
    # SAML Authentication Required Error
    class SAMLAuthenticationRequired < Standard
      # :nocov:
      def to_s
        'SAML authentication is required to access this resource. ' \
          'Please ensure SAML authentication credentials are provided.'
      end
      # :nocov:
    end
  end
end
