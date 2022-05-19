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

  def all_journeys
    sql = "SELECT * FROM journeys"
    result = query(sql)

    result.map do |journey|
      { id: journey["id"].to_i, name: journey["name"] }
    end
  end

  def find_journey(id)
    sql = "SELECT * FROM journeys WHERE id = $1"
    result = query(sql, id)

    tuple = result.first
    { id: tuple["id"].to_i, name: tuple["name"] }
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

  # locations_for_country_view
  def locations_of_country_visiting_on_journey(country_id, journey_id)

  end


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

  def create_journey(name)
    sql = "INSERT INTO journeys(name) VALUES ($1)"
    query(sql, name)
  end

  def query(sql, *params)
    puts sql
    @db.exec_params(sql, params)
  end
end