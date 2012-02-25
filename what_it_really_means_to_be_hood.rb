$:.unshift(File.dirname(__FILE__))

require "sinatra/base"
require "yaml"
require "koala"

class WhatItReallyMeansToBeHoodApp < Sinatra::Base
  set :show_exceptions, false
  set :sessions, true
  set :session_secret, "development" if ENV['RACK_ENV'] == "development"

  configure do
    APP_ID    = ENV["APP_ID"]
    APP_CODE  = ENV["APP_CODE"]
    SITE_URL  = ENV["SITE_URL"]
  end

  get "/" do
    @stats = YAML.load_file("philadelphia_statistics.yml")["statistics"]
    @violent_crime_rate = @stats["violent_crime"]["rate"]
    @unemployment_rate = @stats["unemployment"]["rate"]
    @graduation_rate  = @stats["graduation"]["rate"]
    @poverty_rate  = @stats["poverty"]["rate"]
    "poverty_rate = #{@poverty_rate}"

    if session["access_token"]
      'You are logged in! <a href="/logout">Logout</a>'
      # do some stuff with facebook here
      # for example:
      # @graph = Koala::Facebook::GraphAPI.new(session["access_token"])
      # publish to your wall (if you have the permissions)
      # @graph.put_wall_post("I'm posting from my new cool app!")
      # or publish to someone else (if you have the permissions too ;) )
      # @graph.put_wall_post("Checkout my new cool app!", {}, "someoneelse's id")
    else
      '<a href="/login">Login</a>'
    end
  end

  get "/login" do
    # generate a new oauth object with your app data and your callback url
    session["oauth"] = Koala::Facebook::OAuth.new(APP_ID, APP_CODE, SITE_URL + "callback")
    # redirect to facebook to get your code
    redirect session["oauth"].url_for_oauth_code()
  end

  get "/logout" do
    session["oauth"] = nil
    session["access_token"] = nil
    redirect "/"
  end

  #method to handle the redirect from facebook back to you
  get "/callback" do
    p session["oauth"]
    session["access_token"] = session["oauth"].get_access_token(params[:code])
    redirect "/"
  end
end
