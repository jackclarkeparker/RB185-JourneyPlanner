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
    SELECT country_visits.id, countries.name
      FROM country_visits
     INNER JOIN countries
        ON country_visits.country_id = countries.id
     WHERE journey_id = $1;
    SQL
    result = query(sql, id)

    result.map do |tuple|
      { id: tuple["id"].to_i, country_name: tuple["name"] }
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
    SELECT country_visits.id, countries.name
      FROM country_visits
     INNER JOIN countries
        ON country_visits.country_id = countries.id
     WHERE country_visits.id = $1;
    SQL
    result = query(sql, id)

    tuple = result.first
    { id: tuple["id"].to_i, country_name: tuple["name"] }
  end

  def location_visits_on_country_visit(country_visit_id)
    sql = <<~SQL
    SELECT locations.*
      FROM locations
     INNER JOIN location_visits
        ON location_visits.location_id = locations.id
     WHERE country_visit_id = $1;
    SQL
    result = query(sql, country_visit_id)

    result.map do |tuple|
      { id: tuple["id"].to_i, location_name: tuple["name"] }
    end
  end

  def add_location_visit_to_country_visit(country_visit_id, location_name)
    
  end

  def query(sql, *params)
    puts "#{sql} : #{params}"
    @db.exec_params(sql, params)
  end

  private

  def process_new_country_input(name)
    country = find_country_by_name(name)
    insert_country(name) unless country
  end

  def find_country_by_name(name)
    sql = "SELECT * FROM countries WHERE name = $1"
    result = query(sql, name)
    tuple = result.first

    { id: tuple["id"].to_i, name: tuple["name"] } if tuple
  end

  def insert_country(name)
    sql = "INSERT INTO countries(name) VALUES ($1)"
    query(sql, name)
  end
end