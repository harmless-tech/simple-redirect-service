require "json"
require "kemal"

serve_static false

# Redirect json
def json_load
  json = Hash(String, Hash(String, String)).from_json(File.read("redirects.json"))
  json["redirects"]
end
redirect_list = json_load
puts redirect_list

# Routes
get "/" do |env|
  env.response.content_type = "application/json"
  {
    "name": "Simple Redirect Service",
    "id": "simple-redirect-service",
    "version": "0.1.2",
    "desc": "A simple redirect service, built using crystal lang with kemalcr.",
    "authors": ["harmless-tech"],
    "license": "/license",
    "git": "https://github.com/harmless-tech/simple-redirect-service",
    "issues": "https://github.com/harmless-tech/simple-redirect-service/issues"
  }.to_json
end

get "/license" do |env|
  env.response.content_type = "text/plain"
  render "LICENSE"
end

get "/:id" do |env|
  id = env.params.url["id"]
  env.response.content_type = "text/plain"

  if id.size > 26
    env.response.status = HTTP::Status::URI_TOO_LONG
    next "too long"
  end

  redirect = redirect_list[id]?
  if redirect == nil
    env.response.status = HTTP::Status::NOT_FOUND
    next "not found"
  end

  redirect = redirect.as String

  env.response.content_type = "text/html; charset=utf-8"
  "Redirecting to <a href=\"#{redirect}\" rel=\"noopener noreferrer\">#{redirect}</a>..."

  env.response.redirect(redirect, HTTP::Status::FOUND)
end

# Error routes
error 414 do
  "414 - Redirect ID Too Long"
end

error 404 do
  "404 - No Redirect"
end

error 403 do
  "403 - Access Forbidden"
end

Kemal.config.env = "production"
Kemal.run
