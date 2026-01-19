# frozen_string_literal: true

module PublicSuffix
  # Monkey Patch to include the match logic
  class Domain
    # For Sanity
    def ==(other)
      name == other.name
    end

    # @return [ Boolean ]
    #
    def match?(pattern)
      pattern = PublicSuffix.parse(pattern) unless pattern.is_a?(PublicSuffix::Domain)

      return name == pattern.name unless pattern.trd
      return false unless tld == pattern.tld && sld == pattern.sld

      matching_pattern?(pattern)
    end

    # @deprecated Use {#match?} instead
    # rubocop:disable Naming/PredicateMethod
    def match(pattern)
      warn 'DEPRECATION WARNING: PublicSuffix::Domain#match is deprecated, use #match? instead'
      match?(pattern)
    end
    # rubocop:enable Naming/PredicateMethod

    protected

    # @rturn [ Boolean ]
    def matching_pattern?(pattern)
      pattern_trds = pattern.trd.split('.')
      domain_trds  = trd.split('.')

      case pattern_trds.first
      when '*'
        pattern_trds[1..] == domain_trds[1..]
      when '**'
        pa = pattern_trds[1..]
        pa_size = pa.size

        domain_trds[domain_trds.size - pa_size, pa_size] == pa
      else
        name == pattern.name
      end
    end
  end
end
