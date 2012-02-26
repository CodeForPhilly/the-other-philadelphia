$:.unshift(File.dirname(__FILE__))

require "sinatra/base"
require "yaml"
require "koala"
require "openssl"
require "haml"

require "models/person"
require "models/statistics_assigner"
require "models/friends_loader"

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

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
    @is_logged_in = session["access_token"]
    @mappings = {
      "violent_crime" => "important",
      "unemployed" => "warning",
      "dropout" => "success",
      "poverty" => "info"
    }

    if session["access_token"]
      friends_loader = FriendsLoader.new session["access_token"], @stats
      @friends = friends_loader.get_friends
    else
      people = 10.times.collect { Hash.new }
      assigner = StatisticsAssigner.new people, @stats
      @friends = assigner.assign
    end

    haml :index, :layout => :layout
  end

  get "/login" do
    session["oauth"] = Koala::Facebook::OAuth.new(APP_ID, APP_CODE, SITE_URL + "callback")
    redirect session["oauth"].url_for_oauth_code()
  end

  get "/logout" do
    session["oauth"] = nil
    session["access_token"] = nil
    redirect "/"
  end

  #method to handle the redirect from facebook back to you
  get "/callback" do
    session["access_token"] = session["oauth"].get_access_token(params[:code])
    redirect "/"
  end
end
