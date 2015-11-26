# Hack of the Numeric class
class Numeric
  # @return [ String ] A human readable string of the value
  def bytes_to_human
    units = %w(B KB MB GB TB)
    e     = (Math.log(abs) / Math.log(1024)).floor
    s     = format('%.3f', (abs.to_f / 1024**e))

    s.sub(/\.?0*$/, ' ' + units[e])
  end
end
