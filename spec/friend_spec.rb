require "spec_helper"

describe Friend do
  let(:friend) do
    Friend.new(
      :id => 1, :name => "John Doe",
      :picture => "https://fbcdn.net/photo.jpg",
      :tags => [ "violent_crime", "poverty" ]
    )
  end

  it "should have an ID" do
    friend.id.should == 1
  end

  it "should have a name" do
    friend.name.should == "John Doe"
  end

  it "should have a photo" do
    friend.picture.should == "https://fbcdn.net/photo.jpg"
  end

  it "should have tags" do
    friend.tags.should == [ "violent_crime", "poverty" ]
  end
end
