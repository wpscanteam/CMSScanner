# frozen_string_literal: true

if (Gem.win_platform?)
  begin
    require 'sys/proctable'
  rescue LoadError
    print "Error: Unable to run wpscan\nPlease run 'gem install sys-proctable' for Windows machines\n"
    exit
  end
  include Sys
end


# @param [ String ] file The file path
def redirect_output_to_file(file)
  $stdout.reopen(file, 'w')
  $stdout.sync = true
end

# @return [ Integer ] The memory of the current process in Bytes
def memory_usage
  if (Gem.win_platform?)
    ProcTable.ps(pid: Process.pid).working_set_size
  else
    `ps -o rss= -p #{Process.pid}`.to_i * 1024 # ps returns the value in KB
  end
end
