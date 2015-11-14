require 'minitest/autorun'
require 'timecop'
require File.expand_path('../../../lib/cachier', __FILE__)


describe Cachier do 
  
  describe Cachier::Base do 
    
    before do 
      @cachier = Cachier::Base.new
    end

    it 'has default time to live set to 2 hours' do 
      @cachier.ttl.must_equal 7200
    end

    it 'can store data into the cache for atmost ttl time' do 
      @cachier.cache!('foo', 'bar')
      @cachier.has?('foo').must_equal true 
      @cachier.fetch('foo').must_equal 'bar'
      Timecop.freeze(Time.now + @cachier.ttl + 1) do 
        @cachier.has?('foo').must_equal false
        @cachier.fetch('foo').must_equal nil
      end
    end

    it 'refreshes the ttl every time we set new item' do 
      @cachier.cache!('foo', 'bar')
      @cachier.cache!('other', 'something else')
      Timecop.travel(Time.now + 3600)
      @cachier.has?('foo').must_equal true 
      @cachier.has?('other').must_equal true 
      @cachier.cache!('foo', 'updated value')
      Timecop.travel(Time.now + 3600 + 1)
      @cachier.has?('foo').must_equal true
      @cachier.has?('other').must_equal false
      Timecop.return
    end

    it 'can update the ttl' do 
      @cachier.cache!('foo', 'bar')
      @cachier.use_ttl 1000
      Timecop.freeze(Time.now + 1000 + 1) do 
        @cachier.has?('foo').must_equal false
      end
    end

  end

  it 'can use different slots for storing the data' do 
    Cachier.slot('one').cache!('foo', 1)
    Cachier.slot('two').cache!('foo', 2)
    Cachier.slot('one').fetch('foo').must_equal 1
    Cachier.slot('two').fetch('foo').must_equal 2
  end

end
