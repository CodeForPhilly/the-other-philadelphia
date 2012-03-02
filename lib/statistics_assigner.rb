class StatisticsAssigner
  # Public: Instantiates a StatisticsAssigner object
  #
  # assignees - An Array of arbitrary objects.
  # stats     - An Array of Hashes where the key is a label
  #             and the value is a rate.
  def initialize(assignees, stats)
    @assignees  = assignees
    @stats      = stats
  end

  # Public: Assign tags to a objects based on tag statistics.
  #
  # Examples
  #
  #   friends     = ["Bob", "Sally"]
  #   statistics  = [{"cute"=>0.5}]
  #   
  #   assigner = StatisticsAssigner.new(friends, statistics)
  #   p assigner.assign
  #
  #   [["Sally", ["cute"]]]
  #
  # Returns an Array of Array pairs where the first element is
  # the assignee and the second element is the assigned tag.
  def assign
    assignments = Hash.new([ ])
    count       = @assignees.length

    @stats.each do |stat|
      label = stat.keys.first
      rate  = stat.values.last

      @assignees.sample((rate * count).floor).each do |assignee|
        assignments[assignee] += [ label ]
      end
    end

    assignments.to_a
  end
end
