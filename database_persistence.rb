require "pg"
class DatabasePersistence
  def initialize(logger)
    @db = if Sinatra::Base.production?
            PG.connect(ENV['DATABASE_URL'])
          else
            PG.connect(dbname: "yelping_dog")
          end
    @logger = logger
  end

  def query(statement, *params)
    @logger.info "#{statement}: #{params}"
    @db.exec_params(statement, params)
  end

  def create_wine_hash
    wine = query("SELECT * FROM wine")
    wine_hash = {}
    wine.each do |tuple|
      type = tuple['type']
      name = tuple['name']
      id = tuple['id']
      wine_hash[type] ||= {};
      wine_hash[type][id] = name;
    end
    wine_hash
  end

  def add_wine(type, name)
    query("INSERT INTO wine (type, name) VALUES ($1, $2)", type, name)
  end

  def remove_wine(id)
    query("DELETE FROM wine WHERE id = $1", id)
  end

  def update_all_wines(wine_hash, params)
    params.reject! do |key, wine|
      type = key.scan(/[a-zA-Z]+/)[0]
      id = key.scan(/[0-9]+/)[0]
      wine_hash[type][id] == wine
    end

    wines_to_delete = params.keys.map { |key| key.scan(/[0-9]+/)[0] }
    wines_to_delete.each { |id| remove_wine(id) }

    params.each do |key, wine|
      type = key.scan(/[a-zA-Z]+/)[0]
      add_wine(type, wine)
    end
  end
end