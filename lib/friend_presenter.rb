class FriendPresenter
  # Public: Instantiates a FriendPresenter object
  #
  # friends - An Array of Friend objects.
  # rates   - An Array of Hashes where the key is a label
  #           and the value is a rate.
  # limit   - Number of Friends to limit (default: 102)
  def initialize(friends, rates, limit=102)
    assigner = StatisticsAssigner.new(friends, rates)
    @friends = assigner.assign.collect do |friend_tags|
      friend  = friend_tags.first
      tags    = friend_tags.last

      friend.tags = tags

      friend
    end.reject { |friend| friend.tags.empty? }.take(limit).shuffle
  end

  # Public: Implementing Enumerable#each
  def each(&blk)
    @friends.each(&blk)
  end

  # Public: Implementing Enumerable#size
  def size
    @friends.size
  end
end
