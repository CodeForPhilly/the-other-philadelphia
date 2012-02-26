require "spec_helper"

describe "The Other Philadelphia App" do
  describe "GET /" do
    before(:each) { facebook_request_stubs! }

    it "should show a button to login to Facebook" do
      get "/"

      last_response.ok?
      last_response.body.should =~ /Login to Facebook/
    end

    it "should show a collection of your friends" do
      get "/", { }, "rack.session" => { "access_token" => "token" }

      last_response.ok?
      last_response.body.should =~ /John Doe/
      last_response.body.should =~ /photo\.jpg/
    end
  end
end
