module PublicSuffix
  # Monkey Patch to include a == and match logic
  class Domain
    # TODO: better code for this method
    # rubocop:disable all
    def match(pattern)
      pattern = PublicSuffix.parse(pattern) unless pattern.is_a?(PublicSuffix::Domain)

      return name == pattern.name unless pattern.trd
      return false unless tld == pattern.tld && sld == pattern.sld

      pattern_trds = pattern.trd.split('.')
      domain_trds  = trd.split('.')

      case pattern_trds.first
      when '*'
        pattern_trds[1..pattern_trds.size] == domain_trds[1..domain_trds.size]
      when '**'
        pa = pattern_trds[1..pattern_trds.size]

        domain_trds[domain_trds.size - pa.size, pa.size] == pa
      else
        name == pattern.name
      end
    end
    # rubocop:enable all
  end
end
