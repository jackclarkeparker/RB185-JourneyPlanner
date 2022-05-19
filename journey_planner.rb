require "sinatra"
require "tilt/erubis"

require "pry"

require_relative 'database_persistence'

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
  @journey_name = params[:journey_name].strip
  
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
  journey_id = params[:journey_id]
  @journey = @storage.find_journey(journey_id)
  @countries = @storage.countries_visiting_on_journey(journey_id)

  erb :journey
end

# View page for adding a country
get "/journeys/:journey_id/add_country" do
  @journey
end

# Add a country for a journey
post "/journeys/:journey_id/add_country" do
  # country_name
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
