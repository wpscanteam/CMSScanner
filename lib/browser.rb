require 'typhoeus'

# Singleton used to perform HTTP/HTTPS request to the target
class Browser

  @@instance = nil

  def initialize
  end

  private_class_method :new

  def self.instance
    @@instance ||= new
  end

  def self.reset
    @@instance = nil
  end
end
