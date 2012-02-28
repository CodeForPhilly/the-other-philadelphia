class FriendsLoader
  def initialize(access_token, stats, max_count = 47)
    @access_token = access_token
    @max_count = max_count
    @stats = stats
  end

  def get_friends
      graph = Koala::Facebook::API.new(@access_token)
      friends = graph.get_connections("me", "friends").sample(@max_count)

      # Now that we got the friends, sample!
      assigner = StatisticsAssigner.new friends, @stats
      assignments = assigner.assign

      # Now reduce the assignments to only those afflicted
      afflicted_friends = assignments.select do |asmt|
        !asmt[:statistics].empty?
      end

      # Get all photos in batches of 49
      afflicted_friends_photos = []
      afflicted_friends.each_slice(49) do |friends|
        # Execute a batch API query
        photos = graph.batch do |batch|
          friends.each do |friend|
             batch.get_picture(friend[:person]["id"], :type => "large")
          end
        end
        afflicted_friends_photos.concat(photos)
      end

      # Create a hash of friend's names and profile pictures
      friends_pairs = afflicted_friends.zip(afflicted_friends_photos)

      # Now create Person objects to hold the information
      @friends = friends_pairs.collect do |pair|
        friend_info = pair.first
        photo = pair.last
        Person.new(friend_info[:person]["name"], 
                   photo, friend_info[:statistics])
      end

      @friends
  end
end
