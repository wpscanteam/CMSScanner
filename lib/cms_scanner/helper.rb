# frozen_string_literal: true

# @param [ String ] file The file path
def redirect_output_to_file(file)
  $stdout.reopen(file, 'w')
  $stdout.sync = true
end
