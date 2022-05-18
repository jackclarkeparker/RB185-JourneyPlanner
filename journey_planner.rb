require "sinatra"
require "tilt/erubis"

require "pg"
require "pry"

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


  def all_countries_for_journey(id)

  end

  def find_country_for_journey(journey_id, country_id)

  end

  # To ensure we don't add the same location twice
  def all_locations

  end

  # To ensure we don't add the same country twice
  def all_countries

  end

  def all_locations_for_journey(id)

  end

  def create_journey(name)
    sql = "INSERT INTO journeys(name) VALUES ($1)"
    query(sql, name)
  end

  def query(sql, *params)
    puts sql
    @db.exec_params(sql, params)
  end
end

configure do
  set :erb, :escape_html => true
end

configure(:development) do
  require "sinatra/reloader"
end

before do
  @storage = DatabasePersistence.new
end

def error_for_journey_name(name)
  if name.empty?
    "A name for the journey must be supplied."
  elsif journey_name_in_use?(name)
    "That name is already in use, please choose another."
  elsif invalid_name_chars?(name)
    "Journey name can be constructed with alphanumerics, whitespace, "\
    "hypens, and underscores only."
  end
end

def journey_name_in_use?(name)
  @storage.all_journeys.any? do |existing_journey|
    existing_journey[:name] == name
  end
end

def invalid_name_chars?(name)
  !name.match(/\A[a-z0-9\ _-]+\z/i)
end

# It seems like we'll need similar code for validating country / location names

# View all journeys (homepage)
get "/" do
  @journeys = @storage.all_journeys
  erb :home
end

# View page for creating a new journey
get "/create_journey" do
  erb :create_journey
end

# Create new journey
post "/create_journey" do
  @journey_name = params[:journey_name]
  
  error = error_for_journey_name(@journey_name)
  if error
    status 422
    @storage.set_error_message(error)
    erb :create_journey
  else
    @storage.create_journey(@journey_name)
    redirect "/"
  end
end

# View page for a journey
get "/journeys/:journey_id" do
  @journey = 
end

# View page for adding a country
get "/journeys/:journey_id/add_country" do

end

# Add a country for a journey
post "/journeys/:journey_id/add_country" do

end

# View page for a country in a journey
get "/journeys/:journey_id/countries/:country_id" do

end

# View page for adding a location to a journey
get "/journeys/:journey_id/countries/:country_id/add_location" do

end

# Add a location for a country
post "/journeys/:journey_id/countries/:country_id/add_location" do

end
