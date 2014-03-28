
# @param [ String ] file The file path
def redirect_output_to_file(file)
  $stdout.reopen(file, 'w')
  $stdout.sync = true
  $stderr.reopen($stdout) # Not sure if this is needed
end

# @return [ Integer ] The memory of the current process in Bytes
def memory_usage
  `ps -o rss= -p #{Process.pid}`.to_i * 1024 # ps returns the value in KB
end

# Hack of the Numeric class
class Numeric
  # @return [ String ] A human readable string of the value
  def bytes_to_human
    units = %w(B KB MB GB TB)
    e     = self > 0 ? (Math.log(self) / Math.log(1024)).floor : 0
    s     = format('%.3f', (to_f / 1024**e))

    s.sub(/\.?0*$/, ' ' + units[e])
  end
end
