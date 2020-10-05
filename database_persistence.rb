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
    wine = query("SELECT type, name FROM wine")
    wine_hash = {}
    wine.each do |tuple|
      type = tuple['type'].to_sym
      name = tuple['name']
      wine_hash[type] ||= []
      wine_hash[type].push(name)
    end
    wine_hash
  end

  def add_wine(type, name)
    query("INSERT INTO wine (type, name) VALUES ($1, $2)", type, name)
  end

  def remove_wine(name)
    query("DELETE FROM wine WHERE name = $1", name)
  end

  def update_all_wines(wine_hash, params)
    current_names = []
    wine_hash.each do |_, value|
      current_names += value
    end

    names_to_delete = current_names.reject do |name|
      params.values.include?(name)
    end

    names_to_add = params.reject do |_, name| 
      current_names.include?(name)
    end

    names_to_delete.uniq.each do |name|
      remove_wine(name)
    end

    names_to_add.each do |type, name|
      type = type.chop
      add_wine(type, name)
    end

  end
end