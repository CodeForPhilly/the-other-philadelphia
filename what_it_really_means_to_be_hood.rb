$:.unshift(File.dirname(__FILE__))

require "sinatra/base"
require "yaml"
require "koala"
require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

class WhatItReallyMeansToBeHoodApp < Sinatra::Base
  set :show_exceptions, false
  set :sessions, true
  set :session_secret, "development" if ENV['RACK_ENV'] == "development"

  configure do
    APP_ID    = ENV["APP_ID"]
    APP_CODE  = ENV["APP_CODE"]
    SITE_URL  = ENV["SITE_URL"]
    MAX_COUNT = 40
  end

  get "/" do
    @stats = YAML.load_file("philadelphia_statistics.yml")["statistics"]
    @violent_crime_rate = @stats["violent_crime"]["rate"]
    @unemployment_rate = @stats["unemployment"]["rate"]
    @graduation_rate  = @stats["graduation"]["rate"]
    @poverty_rate  = @stats["poverty"]["rate"]
    @dropout_rate = 1 - @graduation_rate
    @is_logged_in = session["access_token"]

    if session["access_token"]
      graph = Koala::Facebook::API.new(session["access_token"])
      friends = graph.get_connections("me", "friends")[0..MAX_COUNT]

      @photos = graph.batch do |batch|
        friends.each do |friend|
           batch.get_picture(friend["id"], :type => "large")
        end
      end

      # Create a hash of friend's names and profile pictures
      friendsPairs = friends.collect{|friend| friend["name"]}.zip(@photos)
      friendsHash = Hash[friendsPairs]

      "Size: #{@photos.length}"
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
