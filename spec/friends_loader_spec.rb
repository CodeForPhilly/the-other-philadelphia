require "spec_helper"

describe FriendsLoader do
  before(:each) do
    facebook_request_stubs!

    @stats = YAML.load_file("data/philadelphia_statistics.yml")["statistics"]
  end

  let (:loader) { FriendsLoader.new("token", @stats) }
  let (:person) { Person.new("John Doe", "https://fbcdn.net/photo.jpg", [ "violent_crime", "poverty" ]) }

  it "should return a list of friends" do
    loader.get_friends.length == 1
  end

  it "should include John Doe" do
    loaded_friend = loader.get_friends.first

    loaded_friend.name.should == person.name
    loaded_friend.picture.should == person.picture
  end
end

