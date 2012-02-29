require "rack/session/cookie"
require "rack/test"
require "webmock/rspec"
require "json"

require "./the_other_philadelphia"

ENV["RACK_ENV"] = "test"

module TheOtherPhiladelphiaAppTest
  include Rack::Test::Methods

  def app
    TheOtherPhiladelphiaApp
  end

  def facebook_oauth_stubs!
    stub_request(:get, /.*graph\.facebook\.com\/oauth\/access_token.*/).to_return(:body => "access_token=token")
  end

  def facebook_friends_stubs!
    batch_requests  = statistic_assigner_friends.collect do |friend|
      { "method" => "get", "relative_url" => "#{friend[:person]["id"]}/picture?type=large"}
    end
    batch_responses = statistic_assigner_friends.collect do |friend|
      {
        "code" => 200, "headers" => [
          { "name" => "Content-Type", "value" => "text/javascript; charset=UTF-8" },
          { "name" => "Location", "value" => "https://fbcdn.net/photo#{friend[:person]["id"]}.jpg" }
        ], "body" => ""
      }
    end
    stub_request(:get, /.*graph\.facebook\.com\/me\/friends\?access_token=token/).to_return(:body => { "data" => facebook_friends }.to_json)
    stub_request(:post, /.*graph\.facebook\.com\//).with(:body => {
     "access_token" => "token",
     "batch" => batch_requests.to_json
     }).to_return(:body => batch_responses.to_json)
  end

  def facebook_friends
    @facebook_friends ||= begin
      10.times.collect do |friend_id|
        { "id" => friend_id.to_s, "name" => "John Doe" }
      end
    end
  end

  def statistic_assigner_friends
    @statistic_assigner_friends ||= begin
      stats = YAML.load_file("data/philadelphia_statistics.yml")["statistics"]
      10.times.collect do |friend_id|
        {
          :person     => { "name" => "John Doe", "id" => friend_id.to_s },
          :statistics => stats.keys.shuffle
        }
      end
    end
  end
end

RSpec.configure do |c|
  # Include helper for Rack::Test methods
  c.include TheOtherPhiladelphiaAppTest

  # Redefine Rack::Test's default host
  Rack::Test.send(:remove_const, "DEFAULT_HOST")
  Rack::Test.const_set("DEFAULT_HOST", "theotherphiladelphia.org")

  # Enable Rack session manipulation via Rack::Test
  class Rack::Session::Cookie
    def call(env)
      env["rack.session"] ||= { }
      @app.call(env)
    end
  end

  # Disable network connectivity
  WebMock.disable_net_connect!
end
