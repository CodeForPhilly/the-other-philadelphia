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

  def facebook_request_stubs!
    stub_request(:get, /.*graph\.facebook\.com\/oauth\/access_token.*/).to_return(:body => "access_token=token")
    stub_request(:get, /.*graph\.facebook\.com\/me\/friends\?access_token=token/).to_return(:body => {
      "data" => [ { "name" => "John Doe", "id" => "123" } ]
    }.to_json)
    stub_request(:post, /.*graph\.facebook\.com\//).with(:body => {
      "access_token"=>"token",
      "batch"=>"[{\"method\":\"get\",\"relative_url\":\"123/picture?type=large\"}]"
    }).to_return(:body => [ { "code" => 200, "headers" => [
      { "name" => "Content-Type",
        "value" => "text/javascript; charset=UTF-8" },
      { "name" => "Location",
        "value" => "https://fbcdn.net/photo.jpg" }
      ],
      "body" => "" } ].to_json)
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
