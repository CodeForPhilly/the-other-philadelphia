require "spec_helper"

describe StatisticsAssigner do
  let(:assigner) { StatisticsAssigner.new(facebook_friends, rates) }

  it "should assign statistics" do
    tags = assigner.assign.collect { |friend| friend.last }.flatten

    rates.each do |stat|
      label = stat.keys.first
      rate  = stat.values.last

      tags.select { |assigned_tag| label == assigned_tag }.length.should == (rate * 10).floor
    end
  end
end
