$:.unshift(File.dirname(__FILE__))

require "sinatra/base"
require "yaml"
require "koala"
require "openssl"
require "haml"

require "lib/person"
require "lib/statistics_assigner"
require "lib/friends_loader"

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

class TheOtherPhiladelphiaApp < Sinatra::Base
  set :show_exceptions, false if ENV["RACK_ENV"] == "production"
  set :sessions, true
  set :session_secret, "session_secret" unless ENV["RACK_ENV"] == "production"

  configure do
    APP_ID    = ENV["APP_ID"] || "app_id"
    APP_CODE  = ENV["APP_CODE"] || "app_code"
    SITE_URL  = ENV["SITE_URL"] || "site_url"

  end

  get "/" do
    # About text that gets displayed as information for the user.
    @about = "The Other Philadelphia takes the stats of inner-city life, 
      mashes them up with your Facebook friends, and shows what life might 
      be like if you lived in the city."

    @stats = YAML.load_file("data/philadelphia_statistics.yml")["statistics"]
    @is_logged_in = session["access_token"]
    @mappings = {
      "violent_crime" => "important",
      "unemployed" => "warning",
      "dropout" => "success",
      "poverty" => "info"
    }

    if @is_logged_in
      friends_loader = FriendsLoader.new session["access_token"], @stats
      @friends = friends_loader.get_friends
    else
      people = 100.times.collect { Hash.new }
      assigner = StatisticsAssigner.new people, @stats
      @friends = assigner.assign
      p @friends
    end

    haml @is_logged_in ? :index : :splash, :layout => :layout
  end

  get "/login" do
    session["oauth"] = Koala::Facebook::OAuth.new(APP_ID, APP_CODE, SITE_URL + "callback")
    redirect session["oauth"].url_for_oauth_code
  end

  get "/logout" do
    session["oauth"] = nil
    session["access_token"] = nil
    redirect "/"
  end

  get "/callback" do
    session["access_token"] = session["oauth"].get_access_token(params[:code]) if params[:code]

    redirect "/"
  end
end
