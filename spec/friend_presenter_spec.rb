require "spec_helper"

describe FriendPresenter do
  let(:presenter) do
    StatisticsAssigner.any_instance.stub(:assign).and_return(
      [
        [ Friend.new(
          :id => 1, :name => "John Doe",
          :picture => "https://fbcdn.net/photo1.jpg"
        ), [ "violent_crime", "poverty" ] ],
        [ Friend.new(
          :id => 2, :name => "John Doe without tags",
          :picture => "https://fbcdn.net/photo2.jpg"
        ), [ ] ]
      ]
    )

    FriendPresenter.new(Array.new, rates)
  end

  it "should should have a size of 1" do
    presenter.size.should == 1
  end

  it "should only present the first John Doe" do
    presenter.each { |friend| friend.name.should == "John Doe" }
  end
end
