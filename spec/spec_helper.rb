require "./the_other_philadelphia"
require "rack/test"

ENV["RACK_ENV"] = "test"

module TheOtherPhiladelphiaAppTest
  include Rack::Test::Methods

  def app
    TheOtherPhiladelphiaApp
  end
end

RSpec.configure do |c|
  c.include TheOtherPhiladelphiaAppTest
end
