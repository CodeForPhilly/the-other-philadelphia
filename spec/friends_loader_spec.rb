require "spec_helper"

describe FriendsLoader do
  before(:each) do
    facebook_oauth_stubs!
    facebook_friends_stubs!
  end

  let(:friends) do
    assigner = mock(StatisticsAssigner, :assign => statistic_assigner_friends, :people= => [ ])
    FriendsLoader.new("token", assigner).get_friends
  end

  it "should return a list of friends" do
    friends.length.should == 10
  end

  it "should have at least one tag" do
    friends.each { |friend| friend.tags.length.should >= 1 }
  end
end
