require "spec_helper"

describe "Facebook Authentication" do
  before(:each) { facebook_request_stubs! }

  describe "GET /login" do
    it "should redirect to Facebook authorization URL" do
      get "/login"

      last_response.status.should == 302
      last_response.location.should =~ /graph\.facebook\.com/
    end
  end

  describe "GET /logout" do
    it "should redirect to the root" do
      get "/logout"

      last_response.status.should == 302
      last_response.location.should =~ /theotherphiladelphia\.org\//
    end
  end

  describe "GET /callback" do
    it "should set the Facebook access token" do
      get "/callback", { :code => "code" }, "rack.session" => {
        "oauth" => Koala::Facebook::OAuth.new("app_id", "app_code", "site_urlcallback")
      }

      last_response.status.should == 302
      last_request.env["rack.session"]["access_token"].should == "token"
    end
  end

  it "should handle access denied errors gracefully" do
    get "/callback", { :error_reason => "user_denied", :error => "access_denied" }, "rack.session" => {
      "oauth" => Koala::Facebook::OAuth.new("app_id", "app_code", "site_urlcallback")
    }

    last_response.status.should == 302
    last_request.env["rack.session"]["access_denied"].should be_nil
  end
end
