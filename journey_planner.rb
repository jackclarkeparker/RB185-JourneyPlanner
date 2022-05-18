require "sinatra"
require "tilt/erubis"

configure(:development) do
  require "sinatra/reloader"
end

# View all journeys (homepage)
get "/" do
  @journeys = []
  erb :home
end

# View page for creating a new journey
get "/create_journey" do

end

# Create new journey
post "/create_journey" do

end

# View page for a journey
get "/journeys/:journey_id" do

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
