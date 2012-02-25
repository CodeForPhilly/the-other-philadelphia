
class StatisticsAssigner 
  def initialize(people, stats)
    @people = people
    @stats = stats
  end

  def assign
    @assignments = {}
    # @people is array
    peopleAnnotated = @people.collect do |person|
      {
        :person => person,
        :statistics => []
      }
    end
    count = peopleAnnotated.length
    @stats.each do |key, value|
      sample = peopleAnnotated.sample((value["rate"] * count).floor)
      sample.each do | person |
        person[:statistics] << key
      end
    end

    peopleAnnotated
  end
end

