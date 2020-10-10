require "pg"
class DatabasePersistence
  def initialize(logger)
    @db = if Sinatra::Base.production?
            PG.connect(ENV['DATABASE_URL'])
          elsif ENV["RACK_ENV"] == "test"
            PG.connect(dbname: "yelping_dog_test")
          else
            PG.connect(dbname: "yelping_dog")
          end
    @logger = logger
  end

  def query(statement, *params)
    @logger.info "#{statement}: #{params}" unless ENV["RACK_ENV"] == "test"
    @db.exec_params(statement, params)
  end

  def create_wine_hash
    wine = query("SELECT * FROM wine")
    wine_hash = {}
    wine.each do |tuple|
      type = tuple['type']
      name = tuple['name']
      id = tuple['id']
      wine_hash[type] ||= {}
      wine_hash[type][id] = name
    end
    wine_hash
  end

  def add_wine(type, name)
    query("INSERT INTO wine (type, name) VALUES ($1, $2)", type, name)
  end

  def remove_wine(id)
    query("DELETE FROM wine WHERE id = $1", id)
  end

  def filter_existing_wines(params, wine_hash)
    params.reject do |key, wine|
      type = key.scan(/[a-zA-Z]+/)[0]
      id = key.scan(/[0-9]+/)[0]
      wine_hash[type][id] == wine
    end
  end

  def get_old_wine_ids(filtered_params)
    filtered_params.keys.map { |key| key.scan(/[0-9]+/)[0] }
  end

  def update_all_wines(wine_hash, params)
    wines_to_add = filter_existing_wines(params, wine_hash)

    wines_to_delete = get_old_wine_ids(wines_to_add)
    wines_to_delete.each { |id| remove_wine(id) }

    wines_to_add.each do |key, wine|
      type = key.scan(/[a-zA-Z]+/)[0]
      add_wine(type, wine)
    end
  end

  def parse_date(event)
    date = event[:date]
    month = date[0, 2].to_i
    day = date[3, 2].to_i
    year = date[6, 4].to_i
    time = event[:time]
    hour = time[0, 2].to_i
    minute = time[3, 2].to_i
    DateTime.new(year, month, day, hour, minute)
  end

  def event_from_tuple(tuple)
    {
      id: tuple['id'],
      name: tuple['name'],
      date: tuple['date'],
      time: tuple['time'],
      price: tuple['price'],
      description: tuple['description']
    }
  end

  def create_events_array
    events = query("SELECT * FROM events")
    events_array = []
    events.each do |tuple|
      events_array.push(event_from_tuple(tuple))
    end

    events_array.sort_by do |event|
      parse_date(event)
    end
  end

  def add_event(event)
    sql = <<~SQL
      INSERT INTO events (name, date, time, price, description) VALUES
        ($1, $2, $3, $4, $5)
    SQL
    query(sql, event[:name], event[:date], event[:time],
          event[:price], event[:description])
  end

  def update_event(event, id)
    sql = <<~SQL
      UPDATE events SET name = $1, date = $2, time = $3, price = $4,
        description = $5 WHERE id = $6
    SQL
    query(sql, event[:name], event[:date], event[:time],
          event[:price], event[:description], id)
  end

  def delete_event(id)
    query("DELETE FROM events WHERE id = $1", id)
  end

  def disconnect
    @db.close
  end
end
