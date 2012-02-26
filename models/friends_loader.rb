class FriendsLoader
  def initialize(access_token, stats, max_count = 47)
    @access_token = access_token
    @max_count = max_count
    @stats = stats
  end

  def get_friends
      graph = Koala::Facebook::API.new(@access_token)
      friends = graph.get_connections("me", "friends")[0..@max_count]

      photos = graph.batch do |batch|
        friends.each do |friend|
           batch.get_picture(friend["id"], :type => "large")
        end
      end

      # Create a hash of friend's names and profile pictures
      friends_pairs = friends.collect{|friend| friend["name"]}.zip(photos)
      friends_hash = Hash[friends_pairs]

      # Assignments
      assigner = StatisticsAssigner.new friends_pairs, @stats
      assignments = assigner.assign

      @friends = assignments.collect do |assignment|
        Person.new(assignment[:person].first, assignment[:person].last, assignment[:statistics])
      end

      @friends
  end
end
