require "spec_helper"

describe StatisticsAssigner do
  before(:each) { @stats = YAML.load_file("data/philadelphia_statistics.yml")["statistics"] }

  let(:assigner) do
    assigner = StatisticsAssigner.new(@stats)
    assigner.people = facebook_friends

    assigner
  end

  it "should assign statistics" do
    assignments = assigner.assign.collect { |person| person[:statistics] }.flatten

    @stats.keys.each do |stat_label|
      assignments.select { |assigned_stat| stat_label == assigned_stat }.length.should == (@stats[stat_label]["rate"] * 10).floor
    end
  end
end
