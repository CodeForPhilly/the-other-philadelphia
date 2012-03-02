require "spec_helper"

describe FriendLoader do
  before(:each) do
    facebook_oauth_stubs!
    facebook_friends_stubs!
  end

  let(:friends) { FriendLoader.new("token").get_friends }

  it "should return Friend objects" do
    friends.first.class.should == Friend
  end

  it "should return a list of friends" do
    friends.length.should == 10
  end

  it "should return a list of friends who all have photos" do
    friends.each { |friend| friend.picture.should_not be_nil }
  end
end
