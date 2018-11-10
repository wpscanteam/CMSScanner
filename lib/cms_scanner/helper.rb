# @param [ String ] file The file path
def redirect_output_to_file(file)
  $stdout.reopen(file, 'w')
  $stdout.sync = true
end

# @return [ Integer ] The memory of the current process in Bytes
def memory_usage
  `ps -o rss= -p #{Process.pid}`.to_i * 1024 # ps returns the value in KB
end
