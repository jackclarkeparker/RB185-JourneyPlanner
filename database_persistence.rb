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

  # countries_for_journey_view
  def countries_visiting_on_journey(journey_id)
    sql = <<~SQL
    SELECT countries.* FROM countries
      INNER JOIN countries_journeys ON countries_journeys.country_id = countries.id
      WHERE countries_journeys.journey_id = $1;
    SQL
    result = query(sql, journey_id)

    result.map do |tuple|
      { id: tuple["id"].to_i, name: tuple["name"] }
    end
  end

  def add_country_to_journey(journey_id, country_name)
    process_new_country_input(country_name)
    country = find_country_by_name(country_name)

    sql = <<~SQL
    INSERT INTO countries_journeys(journey_id, country_id)
      VALUES ($1, $2)
    SQL

    query(sql, journey_id, country[:id])
  end

  # locations_for_country_view
  # def locations_of_country_visiting_on_journey(country_id, journey_id)

  # end


  # def find_country_for_journey(journey_id, country_id)

  # end

  # To ensure we don't add the same location twice
  # def all_locations

  # end

  # To ensure we don't add the same country twice
  # def all_countries

  # end

  # def all_locations_for_journey(id)

  # end

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