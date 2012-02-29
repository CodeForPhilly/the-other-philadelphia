class FriendsLoader
  BATCH_API_LIMIT = 49

  def initialize(access_token, assigner, max_count = 102)
    @access_token = access_token
    @assigner     = assigner
    @max_count    = max_count
  end

  def get_friends
      graph = Koala::Facebook::API.new(@access_token)
      friends = graph.get_connections("me", "friends")

      # Now that we got the friends, sample!
      @assigner.people  = friends
      assignments       = @assigner.assign

      # Now reduce the assignments to only those afflicted
      afflicted_friends = assignments.reject { |asmt| asmt[:statistics].empty? }

      # Now limit and randomize
      afflicted_friends = afflicted_friends.take(@max_count).shuffle

      # Get all photos in batches of BATCH_API_LIMIT
      afflicted_friends_photos = []
      afflicted_friends.each_slice(BATCH_API_LIMIT) do |friends|
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
