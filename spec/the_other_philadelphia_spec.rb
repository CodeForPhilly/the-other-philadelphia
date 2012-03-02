require "spec_helper"

describe "The Other Philadelphia App" do
  describe "GET /" do
    before(:each) do
      facebook_oauth_stubs!
      facebook_friends_stubs!

      FriendPresenter.any_instance.stub(:each).and_yield(
        Friend.new(
          :id => 1, :name => "John Doe",
          :picture => "https://fbcdn.net/photo.jpg",
          :tags => [ "violent_crime", "poverty" ]
        )
      )
    end

    it "should show a button to login to Facebook" do
      get "/"

      last_response.ok?
      last_response.body.should =~ /Login to Facebook/
    end

    it "should show a collection of your friends" do
      get "/", { }, "rack.session" => { "access_token" => "token" }

      last_response.ok?
      last_response.body.should =~ /John Doe/
      last_response.body.should =~ /Violent crime/
      last_response.body.should =~ /Poverty/
    end
  end
end
