require 'simplecov'
SimpleCov.start

ENV["RACK_ENV"] = "test"

require "minitest/autorun"
require "rack/test"

require_relative "../controller"

class ControllerTest < Minitest::Test
  include Rack::Test::Methods
  
  def app
    Sinatra::Application
  end

  def session
    last_request.env["rack.session"]
  end

  def logged_in
    { "rack.session" => { logged_in: true } }
  end

  def new_event_params
    {
      'name' => "Italian Wine Tasting",
      'month' => '10',
      'day' => '31',
      'year' => '2020',
      'start-hour' => '06',
      'start-minute' => '00',
      'start-period' => 'pm',
      'end-hour' => '07',
      'end-minute' => '00',
      'end-period' => 'pm',
      'price' => 'free',
      'description' => 'Come join us for an Italian Wine Tasting!'
    }
  end

  def edit_event_params
    {
      'name' => "Paint and Drink",
      'month' => '10',
      'day' => '31',
      'year' => '2020',
      'start-hour' => '06',
      'start-minute' => '00',
      'start-period' => 'pm',
      'end-hour' => '07',
      'end-minute' => '00',
      'end-period' => 'pm',
      'price' => 'free',
      'description' => 'Come join us for paint and drink!'
    }
  end

  def wine_params(wine_hash)
    params = {}
    wine_hash.each do |type, type_hash|
      type_hash.each do |id, wine|
        key = (type + id).to_sym
        params[key] = type + ' wine'
      end
    end
    params
  end

  def setup
    @storage = DatabasePersistence.new('logger')
    @storage.query("DELETE FROM events")
    @storage.query("DELETE FROM wine")
    sql_wine = <<~SQL
      INSERT INTO wine (type, name) VALUES
        ('red', 'Screaming Eagle Cabernet Sauvignon, 1992, Oakville, Napa Valley, CA'),
        ('red', 'DRC Romanee-Conti, 1995, Vosne-Romaneè, Burgundy, France'),
        ('red', 'Vietti Ravera, 2001, Barolo, Italy'),
        ('red', 'Chateau Petrus, 1975, Pomerol, Bourdeaux, France'),
        ('red', 'Penfolds Grange, 1999, South Australia'),
        ('white', 'Domaine Leflaive Montrachet, 2007, Puligny-Montrachet, Burgundy, France'),
        ('white', 'Chateau Montalena Chardonnay 2012, Napa Valley, CA'),
        ('white', 'Domaine Georges Vernay, 2017, Condrieu, Rhone, France'),
        ('white', 'Egon Müller Scharzhofberger Riesling Auslese, 2014, Mosel, Germany'),
        ('white', 'Seresin Marama Sauvignon Blanc, 2013, Marlborough, New Zealand'),
        ('bubbly', 'Dom Perignon Brut, 2002, Champagne, France'),
        ('bubbly', 'Schramsberg Brut Rose, 2017, Napa Valley, CA')
    SQL

    sql_events = <<~SQL
      INSERT INTO events (name, date, time, price, description) VALUES
        ('Argentinian Wine Tasting', '10/13/2020', '06:30pm - 07:30pm',
          'Free', 'Come join us for a tasting of wines from Argentina. Señor Vino has been making wine in the Mendoza region of Argentina for 20 years. The high altitude provides excellent growing conditions for Malbec and Torrontes, the two grape varieties planted at his vineyard.'),
        ('Paint and Sip', '10/25/2020', '07:00pm - 08:00pm', '$25',
          'Learn how to paint while enjoying a glass of wine! This week we have local artist Banksy joining us in a guided painting of a red balloon. In keeping with tradition, the painting must be shredded upon completion. The remains will be packaged in a to go bag to remember the event.')
    SQL

    @storage.query(sql_wine)
    @storage.query(sql_events)
    @wine_hash = @storage.create_wine_hash
    @events = @storage.create_events_array
    event_sql = "SELECT id FROM events WHERE name = 'Paint and Sip'"
    wine_sql = "SELECT id FROM wine WHERE name = 'Screaming " \
               "Eagle Cabernet Sauvignon, 1992, Oakville, Napa Valley, CA'"
    @paint_event_id = @storage.query(event_sql).getvalue(0,0)
    @screaming_eagle_id = @storage.query(wine_sql).getvalue(0,0)
  end

  def teardown
    @storage.disconnect
  end

  def test_main_page_redirect
    get "/"
    assert_equal 302, last_response.status

    get last_response["Location"]
    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "<h1>Yelping Dog Wine</h1>"
  end

  def test_home_page
    get "/home"
    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "<h1>Yelping Dog Wine</h1>"
  end

  def test_about_page
    get "/about"
    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "<div class=\"about-wrapper\">"
  end

  def test_wine_menu_page_not_logged_in
    get "/wine_menu"
    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "Penfolds Grange, 1999, South Australia"
    assert_includes last_response.body, "<h2>This Week's Wines by the Glass</h2>"
    refute_includes last_response.body, "<form action=\"/edit\" method=\"get\" id=\"edit\">"
  end

  def test_wine_menu_page_logged_in
    get "/wine_menu", {}, logged_in
    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "Penfolds Grange, 1999, South Australia"
    assert_includes last_response.body, "<h2>This Week's Wines by the Glass</h2>"
    assert_includes last_response.body, "<form action=\"/edit\" method=\"get\" id=\"edit\">"
  end

  def test_edit_wine_menu_page_not_logged_in
    get "/edit"
    assert_equal 302, last_response.status
    
    get last_response["Location"]
    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "Log in to make changes"
  end

  def test_edit_wine_menu_page_logged_in
    get "/edit", {}, logged_in
    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    html = "<button type=\"submit\" form=\"submit-changes\">Submit " \
           "Changes</button>"
    assert_includes last_response.body, html
    assert_includes last_response.body, "Penfolds Grange, 1999, South Australia"
  end

  def test_events_page_not_logged_in
    get "/events"
    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "<h2 class=\"event\">Upcoming Events</h2>"
    assert_includes last_response.body, "Paint and Sip"
    refute_includes last_response.body, "<input type=\"checkbox\" id=\"add-event\" hidden/>"
  end

  def test_events_page_logged_in
    get "/events", {}, logged_in
    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "<h2 class=\"event\">Upcoming Events</h2>"
    assert_includes last_response.body, "Paint and Sip"
    assert_includes last_response.body, "<input type=\"checkbox\" id=\"add-event\" hidden/>"
  end

  def test_admin_page_not_logged_in
    get "/admin"
    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "Log in to make changes"
    refute_includes last_response.body, "You are logged in"
  end

  def test_admin_page_logged_in
    get "/admin", {}, logged_in
    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    refute_includes last_response.body, "Log in to make changes"
    assert_includes last_response.body, "You are logged in"
  end

  def test_logging_in
    post "/admin", { username: "Admin", password: "Cabernet123" }
    assert_equal 302, last_response.status
    assert_equal true, session[:logged_in]

    get last_response["Location"]
    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "<h2>This Week's Wines by the Glass</h2>"
    assert_includes last_response.body, "<form action=\"/edit\" method=\"get\" id=\"edit\">"
  end

  def test_logging_in_with_invalid_credentials
    post "/admin", { username: "Invalid_user", password: "Wrong_password" }
    assert_equal 302, last_response.status
    assert_equal "Incorrect username or password", session[:error]

    get last_response["Location"]
    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "Log in to make changes"
    refute_includes last_response.body, "You are logged in"
    assert_includes last_response.body, "Incorrect username or password"
  end

  def test_logging_out
    post "/logout", {}, logged_in
    assert_equal false, session[:logged_in]
    assert_equal 302, last_response.status

    get last_response["Location"]
    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "Log in to make changes"
  end

  def test_add_event
    post "/add/event", new_event_params, logged_in
    assert_equal 302, last_response.status

    get last_response["Location"]
    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "<h2 class=\"event\">Upcoming Events</h2>"
    assert_includes last_response.body, "Paint and Sip"
    assert_includes last_response.body, "<input type=\"checkbox\" id=\"add-event\" hidden/>"
    assert_includes last_response.body, "Italian Wine Tasting"
  end

  def test_edit_event
    post "/edit/event/#{@paint_event_id}", edit_event_params, logged_in
    assert_equal 302, last_response.status

    get last_response["Location"]
    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "<h2 class=\"event\">Upcoming Events</h2>"
    refute_includes last_response.body, "Paint and Sip"
    assert_includes last_response.body, "Paint and Drink"
  end

  def test_delete_event
    post "/delete/event/#{@paint_event_id}", {}, logged_in
    assert_equal 302, last_response.status

    get last_response["Location"]
    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "<h2 class=\"event\">Upcoming Events</h2>"
    refute_includes last_response.body, "Paint and Sip"
  end

  def test_update_wines
    post "/edit", wine_params(@wine_hash), logged_in
    assert_equal 302, last_response.status

    get last_response["Location"]
    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    refute_includes last_response.body, 'Screaming Eagle Cabernet Sauvignon, 1992, Oakville, Napa Valley, CA'
    assert_includes last_response.body, 'red wine'
    assert_includes last_response.body, 'white wine'
    assert_includes last_response.body, 'bubbly wine'
  end

  def test_delete_wine
    post "/remove/red/#{@screaming_eagle_id}", {}, logged_in
    assert_equal 302, last_response.status

    get last_response["Location"]
    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    refute_includes last_response.body, 'Screaming Eagle Cabernet Sauvignon, 1992, Oakville, Napa Valley, CA'
  end
end