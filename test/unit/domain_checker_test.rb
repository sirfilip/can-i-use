require 'minitest/autorun'

require File.expand_path('../../../lib/domain_checker', __FILE__)

describe DomainChecker do 
  before do 
    @domain_checker = DomainChecker::Base.new
  end

  it 'returns true for available domains' do 
    available_domain = 'yadadada' * 10 + '.com'
    @domain_checker.available?(available_domain).must_equal true
  end

  it 'returns false for taken domains' do 
    domain_taken = 'google.com'
    @domain_checker.available?(domain_taken).must_equal false
  end

  it 'raises error if not a proper domain name' do 
    bad_domain_name = 'something weird' 
    lambda do 
      @domain_checker.available?(bad_domain_name)
    end.must_raise DomainChecker::BadFormatedDomain
  end
  
  it 'uses shorthand for domain checking' do 
    DomainChecker.check('google.com').must_equal false
  end

end
