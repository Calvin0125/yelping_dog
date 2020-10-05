require "sinatra"
require "sinatra/content_for"
require "tilt/erubis"
require_relative "database_persistence"

configure do
  enable :sessions
end

configure(:development) do
  require "sinatra/reloader"
  also_reload "database_persistence.rb"
end

before do
  @storage = DatabasePersistence.new(logger)
  @wine_hash = @storage.create_wine_hash
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

get "/wine_menu" do
  erb :wine_menu, layout: :layout
end

get "/admin" do
  erb :admin, layout: :layout
end

post "/admin" do
  if params[:username] == "Admin" && params[:password] == "Cabernet123"
    session[:logged_in] = true
    redirect "/wine_menu"
  else
    session[:error] = "Incorrect username or password"
    redirect "/admin"
  end
end

post "/logout" do
  session[:logged_in] = false
  redirect "/admin"
end

get "/edit" do
  erb :edit, layout: :layout
end

post "/edit" do
  @storage.update_all_wines(@wine_hash, params)
  redirect "/wine_menu"
end

post "/add/:type" do |type|
  @storage.add_wine(type, 'New wine here...')
  redirect "/edit##{type}"
end

post "/remove/:type/:name" do |type, name|
  @storage.remove_wine(name)
  redirect "/edit##{type}"
end
