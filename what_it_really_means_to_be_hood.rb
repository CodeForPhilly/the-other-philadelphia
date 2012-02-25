$:.unshift(File.dirname(__FILE__))

require "sinatra/base"

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
    "Hello, world."
  end
end
