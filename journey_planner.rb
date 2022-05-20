require "sinatra"
require "tilt/erubis"

require "pry"

require_relative 'database_persistence'

configure do
  set :erb, :escape_html => true
end

configure(:development) do
  require "sinatra/reloader"
  also_reload "database_persistence.rb"
end

before do
  @storage = DatabasePersistence.new
end

def parent_route
  request.path[/\A.*(?=\/)/]
end

def error_for_journey_name(name)
  if name.empty?
    "A name for the journey must be supplied."
  elsif journey_name_in_use?(name)
    "That name is already in use, please choose another."
  elsif invalid_name_chars?(name)
    "Journey names can be constructed with alphabetical characters, "\
    "whitespace, and hyphens only"
  end
end

def journey_name_in_use?(name)
  @storage.all_journeys.any? do |existing_journey|
    existing_journey[:name] == name
  end
end

def invalid_name_chars?(name)
  !name.match(/\A[a-z\ -]+\z/i)
end

def error_for_country_name(name)
  if name.empty?
    "A name for the country must be supplied."
  elsif invalid_name_chars?(name)
    "Country names can be constructed with alphabetical characters, "\
    "whitespace, and hyphens only"
  end
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
  @journey = @storage.find_journey_by_id(journey_id)
  @country_visits = @storage.country_visits_on_journey(journey_id)

  erb :journey
end

# View page for adding a country
get "/journeys/:journey_id/add_country" do
  journey_id = params[:journey_id]
  @journey = @storage.find_journey_by_id(journey_id)
  # Retrieving countries here just to see if it's empty to display alternate
  # prompt in add_country view. Maybe a good instance to add this functionality
  # to journey hash objects or the Journey class
  @country_visits = @storage.country_visits_on_journey(journey_id)

  erb :add_country
end

# Add a country for a journey
post "/journeys/:journey_id/add_country" do
  @country_name = params[:country_name]

  error = error_for_country_name(@country_name)
  if error
    status 422
    @storage.set_error_message(error)
    erb :add_country
  else
    journey_id = params[:journey_id]
    @storage.add_country_to_journey(journey_id, @country_name)
    redirect parent_route
  end
end

# View page for a country in a journey
get "/journeys/:journey_id/countries/:country_id" do # Change country_id to c_visit_id?
  @journey = @storage.find_journey_by_id(params[:journey_id])
  @country_visit = @storage.find_country_visit(params[:country_id])
  @location_visits = @storage.location_visits_on_country_visit(@country_visit[:id])

  erb :country
end

# View page for adding a location to a journey
get "/journeys/:journey_id/countries/:country_id/add_location" do

end

# Add a location for a country
post "/journeys/:journey_id/countries/:country_id/add_location" do

end
