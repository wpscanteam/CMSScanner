
# @param [ String ] file The file path
def redirect_output_to_file(file)
  $stdout.reopen(file, 'w')
  $stdout.sync = true
  $stderr.reopen($stdout) # Not sure if this is needed
end
