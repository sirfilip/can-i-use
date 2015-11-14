require 'whois'
require 'logger'

module DomainChecker
  class BadFormatedDomain < StandardError
  end
  
  def self.check(domain)
    client = Base.new
    client.available?(domain)
  end


  class Base

    attr_reader :client

    def initialize
      @client = Whois::Client.new
    end

    def available?(domain)
      result = client.lookup(domain)
      result.available?
    rescue StandardError => e
      puts e.message
      raise BadFormatedDomain.new("domain #{domain} is not a vaild domain name")
    end

  end

end
