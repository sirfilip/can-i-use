require 'sinatra'
require './lib/domain_checker'
require './lib/cachier'

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


__END__
@@layout
<!doctype html>
<html>
<head>
<title>Domain Checker</title>
</head>
<body>
  <%= yield %>
</body>
</html>

@@index
<h1>Check If Domain is Available</h1>
<form action="." method="POST">
  <label for="domain">Domain</label>
  <input type="text" name="domain" id="domain" placeholder="Enter Domain To Check" value="<%= params['domain'] %>" />
  <input type="submit" />
</form>
<%= @message %>
