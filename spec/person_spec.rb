require "spec_helper"

describe Person do
  let (:person) { Person.new("John Doe", "https://fbcdn.net/photo.jpg", [ "violent_crime", "poverty" ]) }

  it "should have a name" do
    person.name.should == "John Doe"
  end

  it "should have a photo" do
    person.picture.should == "https://fbcdn.net/photo.jpg"
  end

  it "should have tags" do
    person.tags.should == [ "violent_crime", "poverty" ]
  end
end
