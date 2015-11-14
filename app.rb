require 'sinatra/base'
require './lib/domain_checker'
require './lib/cachier'

class CanIUse < Sinatra::Base

  helpers do 
    def json(data)
      content_type :json
      data.to_json
    end
    
    def cached(key) 
      if Cachier.slot('domains').has?(key)
        Cachier.slot('domains').fetch(key)
      else
        contents = yield 
        Cachier.slot('domains').cache!(key, contents)
        contents
      end
    end

    def title(new_title) 
      @_page_title = new_title
    end
  end

  get '/' do 
    erb :index
  end

  post '/' do 
    if DomainChecker.check(params['domain'])
      @message = "Domain #{params['domain']} is available"
    else
      @message = "Domain #{params['domain']} is taken"
    end
    erb :index
  end

  get '/api/v1/:domain' do |domain| 
    begin
      available = cached(domain) do 
        DomainChecker.check(domain)
      end
      json({"domain" => domain, "available" => available})
    rescue DomainChecker::BadFormatedDomain => e
      json({"error" => true, "message" => e.message})
    end
  end

end

