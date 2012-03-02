$:.unshift(File.dirname(__FILE__))

require "sinatra/base"
require "yaml"
require "koala"
require "openssl"
require "haml"

require "lib/friend"
require "lib/statistics_assigner"
require "lib/friend_loader"
require "lib/friend_presenter"

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

  helpers do
    def partial(page, options={ })
      haml page, options.merge!(:layout => false)
    end

    def rates
      @stats.collect { |k, v| { k => v["rate"] } }
    end

    def label(tag)
      mappings = {
        "violent_crime" => "important",
        "unemployed" => "warning",
        "dropout" => "success",
        "poverty" => "info"
      }[tag]
    end
  end

  get "/" do
    # How should @city be set later?
    @city = "Philadelphia"

    yaml_contents = YAML.load_file("data/#{@city.downcase.gsub(/[^\da-z]/, "_")}.yml")
    @stats = yaml_contents["statistics"]
    @organizations = yaml_contents["organizations"]
    @is_logged_in = session["access_token"]

    if @is_logged_in
      friends = FriendLoader.new(session["access_token"]).get_friends
      @annotated_friends = FriendPresenter.new(friends, rates)
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
