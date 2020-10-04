require "sinatra"
require "sinatra/content_for"
require "tilt/erubis"

configure do
  enable :sessions
  set :session_secret, 'secret'
end

configure(:development) do
  require "sinatra/reloader"
end

before do
  @wine_hash = {
    red: [
      "Screaming Eagle Cabernet Sauvignon, 1992, Oakville, Napa Valley, CA",
      "DRC Romanee-Conti, 1995, Vosne-Romaneè, Burgundy, France",
      "Vietti Ravera, 2001, Barolo, Italy",
      "Chateau Petrus, 1975, Pomerol, Bourdeaux, France",
      "Penfolds Grange, 1999, South Australia"
    ],
    white: [
      "Domaine Leflaive Montrachet, 2007, Puligny-Montrachet, Burgundy, France",
      "Chateau Montalena Chardonnay 2012, Napa Valley, CA",
      "Domaine Georges Vernay, 2017, Condrieu, Rhone, France",
      "Egon Müller Scharzhofberger Riesling Auslese, 2014, Mosel, Germany",
      "Seresin Marama Sauvignon Blanc, 2013, Marlborough, New Zealand"
    ],
    bubbly: [
      "Dom Perignon Brut, 2002, Champagne, France",
      "Schramsberg Brut Rose, 2017, Napa Valley, CA"
    ]
  }
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