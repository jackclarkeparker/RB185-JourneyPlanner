require "pg"

class DatabasePersistence
  attr_reader :message

  def set_error_message(message)
    @message[:error] = message
  end

  def set_success_message(message)
    @message[:success] = message
  end

  def initialize
    @db = PG.connect(dbname: 'journey_planner')
    @message = {}
  end

  def find_journey(id)
    sql = "SELECT * FROM journeys WHERE id = $1"
    result = query(sql, id)

    tuple = result.first
    { id: tuple["id"].to_i, name: tuple["name"] }
  end

  def all_journeys
    sql = "SELECT * FROM journeys"
    result = query(sql)

    result.map do |tuple|
      { id: tuple["id"].to_i, name: tuple["name"] }
    end
  end

  def create_journey(name)
    sql = "INSERT INTO journeys(name) VALUES ($1)"
    query(sql, name)
  end

  def country_visits_on_journey(id)
    sql = <<~SQL
    SELECT country_visits.id, countries.name,
           countries.id AS country_id
      FROM country_visits
     INNER JOIN countries
        ON country_visits.country_id = countries.id
     WHERE journey_id = $1;
    SQL
    result = query(sql, id)

    result.map do |tuple|
      { id: tuple["id"].to_i,
        country_name: tuple["name"],
        country_id: tuple["country_id"] }
    end
  end

  def add_country_visit_to_journey(journey_id, country_name)
    process_new_country_input(country_name)
    country = find_country_by_name(country_name)

    sql = <<~SQL
    INSERT INTO country_visits(journey_id, country_id)
      VALUES ($1, $2)
    SQL

    query(sql, journey_id, country[:id])
  end

  def find_country_visit(id)
    sql = <<~SQL
    SELECT country_visits.id, countries.name,
           countries.id AS country_id
      FROM country_visits
     INNER JOIN countries
        ON country_visits.country_id = countries.id
     WHERE country_visits.id = $1;
    SQL
    result = query(sql, id)

    tuple = result.first
    { id: tuple["id"].to_i,
      country_name: tuple["name"],
      country_id: tuple["country_id"] }
  end

  def location_visits_on_country_visit(country_visit_id)
    sql = <<~SQL
    SELECT location_visits.id, locations.name
      FROM location_visits
     INNER JOIN locations
        ON location_visits.location_id = locations.id
     WHERE country_visit_id = $1;
    SQL
    result = query(sql, country_visit_id)

    result.map do |tuple|
      { id: tuple["id"].to_i, location_name: tuple["name"] }
    end
  end

  def add_location_visit_to_country_visit(country_visit_id, location_name)
    process_new_location_input(location_name, country_visit_id)
    location = find_location_by_name(location_name)

    sql = <<~SQL
    INSERT INTO location_visits(country_visit_id, location_id)
      VALUES ($1, $2)
    SQL

    query(sql, country_visit_id, location[:id])
  end

  def query(sql, *params)
    puts "#{sql} : #{params}"
    @db.exec_params(sql, params)
  end

  private

  def process_new_country_input(name)
    country = find_country_by_name(name)
    create_country_entry(name) unless country
  end

  def find_country_by_name(name)
    sql = "SELECT * FROM countries WHERE name = $1"
    result = query(sql, name)
    tuple = result.first

    { id: tuple["id"].to_i } if tuple
  end

  def create_country_entry(name)
    sql = "INSERT INTO countries(name) VALUES ($1)"
    query(sql, name)
  end

  def process_new_location_input(name, country_visit_id)
    country_id = find_country_visit(country_visit_id)[:country_id]

    location = find_location_by_name(name)
    create_location_entry(name, country_id) unless location
  end

  def find_location_by_name(name)
    sql = "SELECT * FROM locations WHERE name = $1"
    result = query(sql, name)
    tuple = result.first

    { id: tuple["id"].to_i } if tuple
  end

  def create_location_entry(name, country_id)
    sql = "INSERT INTO locations(name, country_id) VALUES ($1, $2)"
    query(sql, name, country_id)
  end
end
