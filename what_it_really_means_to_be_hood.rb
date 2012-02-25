$:.unshift(File.dirname(__FILE__))

require "sinatra/base"
require "yaml"

#require "models/facility"
#require "models/inspection"
#require "models/infraction"

class WhatItReallyMeansToBeHoodApp < Sinatra::Base
  set :show_exceptions, false

#  configure do
#    Ohm.connect
#  end

#  before do
#    content_type :json
#  end

  get "/" do
    @stats = YAML.load_file("philadelphia_statistics.yml")["statistics"]
    @violent_crime_rate = @stats["violent_crime"]["rate"]
    @unemployment_rate = @stats["unemployment"]["rate"]
    @graduation_rate  = @stats["graduation"]["rate"]
    @poverty_rate  = @stats["poverty"]["rate"]
    "poverty_rate = #{@poverty_rate}"
  end
end
