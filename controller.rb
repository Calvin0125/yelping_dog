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

helpers do
  def format_time(params)
    start_time = "#{params['start-hour']}:#{params['start-minute']}" \
                "#{params['start-period']}"
    end_time = "#{params['end-hour']}:#{params['end-minute']}" \
              "#{params['end-period']}"
    "#{start_time} - #{end_time}"
  end

  def event_from_params(params)
    date = "#{params['month']}/#{params['day']}/#{params['year']}"
    time = format_time(params)
    {
      name: params['name'],
      date: date,
      time: time,
      price: params['price'],
      description: params['description']
    }
  end
end

before do
  @storage = DatabasePersistence.new(logger)
  @wine_hash = @storage.create_wine_hash
  @events = @storage.create_events_array
end

after do
  @storage.disconnect
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

get "/events" do
  erb :events, layout: :layout
end

post "/add/event" do
  @storage.add_event(event_from_params(params))
  redirect "/events"
end

post "/edit/event/:id" do |id|
  @storage.update_event(event_from_params(params), id)
  redirect "/events"
end

post "/delete/event/:id" do |id|
  @storage.delete_event(id)
  redirect "/events"
end

post "/edit" do
  @storage.update_all_wines(@wine_hash, params)
  redirect "/wine_menu"
end

post "/add/:type" do |type|
  @storage.add_wine(type, 'New wine here...')
  redirect "/edit##{type}"
end

post "/remove/:type/:id" do |type, id|
  @storage.remove_wine(id)
  redirect "/edit##{type}"
end
