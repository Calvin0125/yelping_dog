require "sinatra"
require "sinatra/content_for"
require "tilt/erubis"

configure(:development) do
  require "sinatra/reloader"
end

get "/" do
  redirect "/home"
end

get "/home" do
  erb :home, layout: :layout
end

get "/about" do
  erb :about, layout: :layout
end