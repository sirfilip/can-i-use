module Cachier 

  def self.slot(name)
    @slots ||= {}
    unless @slots.has_key?(name) 
      @slots[name] = Base.new
    end
    @slots.fetch(name)
  end

  class Base

    attr_reader :ttl

    def initialize(ttl = 3600 * 2)
      @ttl = ttl  
    end

    def use_ttl(new_ttl)
      @ttl = new_ttl
      self
    end

    def cache 
      @cache ||= Hash.new
    end

    def cache!(key, content) 
      cache[key] = {"data" => content, "created" => Time.now.to_i}
    end
    
    def fetch(key) 
      if  has?(key)
        cache.fetch(key).fetch("data")
      else
        cache.delete(key)
        nil
      end
    end
    
    def has?(key) 
      cache.has_key?(key) && Time.now.to_i - cache.fetch(key).fetch("created") < ttl
    end
  end
  
end
