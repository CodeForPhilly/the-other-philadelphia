class StatisticsAssigner
  attr_writer :people
  
  def initialize(stats)
    @stats = stats
  end

  def assign
    @assignments = {}
    # @people is array
    people_annotated = @people.collect do |person|
      {
        :person => person,
        :statistics => []
      }
    end
    count = people_annotated.length
    @stats.each do |key, value|
      sample = people_annotated.sample((value["rate"] * count).floor)
      sample.each do | person |
        person[:statistics] << key
      end
    end

    people_annotated
  end
end

