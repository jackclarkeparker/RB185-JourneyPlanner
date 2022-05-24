ENV["RACK_ENV"] = 'test'

require 'minitest/autorun'
require 'rack/test'

require_relative '../journey_planner'

# Retrieve SQL to build test database
test_db_deletion = File.read('test_db_deletion.sql')
test_db_creation = File.read('test_db_creation.sql') 
schema = File.read('../schema.sql')

# Run SQL to build test database
PG.connect().exec(test_db_deletion)
PG.connect().exec(test_db_creation)
PG.connect(dbname: 'test_db_journey_planner').exec(schema)

class JourneyPlannerTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def create_journey

  end

  # I'm not entirely sure whether we'll need this or not.
  # def session  
  #   last_request.env["rack.session"]
  # end

  def test_visit_home_page_no_journeys
    get "/"

    assert_equal 200, last_response.status
    assert_includes last_response.body, "<p>It looks like you haven't got any journeys planned right now..."
    assert_includes last_response.body, %q(<a href="/create_journey">create a new one?</a>)
  end

  def test_visit_home_page_with_journeys
    # Creating a journey, may pay to push this into its own method
    post "/create_journey", { journey_name: "Foo Journey" }
    
    get "/"

    assert_equal 200, last_response.status
    assert_includes last_response.body, %q(<li><a href="/journeys/1">Foo Journey</a></li>)
    assert_includes last_response.body, %q(<a href="/create_journey">Create a new journey...</a>)
  end

  # def test_add_country
end