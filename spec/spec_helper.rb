require "./what_it_really_means_to_be_hood"
require "rack/test"

ENV["RACK_ENV"] = "test"

module WhatItReallyMeansToBeHoodAppTest
  include Rack::Test::Methods

  def app
    WhatItReallyMeansToBeHoodApp
  end
end

RSpec.configure do |c|
  c.include WhatItReallyMeansToBeHoodAppTest
end
