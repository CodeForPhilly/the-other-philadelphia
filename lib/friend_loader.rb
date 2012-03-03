class FriendLoader
  BATCH_API_LIMIT = 49

  # Public: Instantiates a FriendLoader object
  #
  # access_token -  An access token returned by the Facebook
  #                 OAuth exchange.
  def initialize(access_token)
    @access_token = access_token
  end

  # Public: Gets a collection of your friends from Facebook
  # and produces a collection of Friend objects with pictures.
  #
  # Examples
  #
  #   loader = FriendLoader.new("token")
  #   p loader.get_friends
  #
  #   [#<Friend:0x007f80e9145b60 @id="1", @name="John Doe", @picture="http://facebook.com/photo.jpg", @tags=[]>]
  #
  # Returns an Array of Friend objects.
  def get_friends
    graph = Koala::Facebook::API.new(@access_token)

    # Get friends from Facebook and convert them into a Friend object
    friends = graph.get_connections("me", "friends").collect do |friend|
      Friend.new(:id => friend["id"], :name => friend["name"])
    end

    # Batch request friend pictures with respect to BATCH_API_LIMIT
    pictures = Array.new
    friends.each_slice(BATCH_API_LIMIT) do |friends_slice|
      batch_pictures = graph.batch do |batch|
        friends_slice.each { |friend| batch.get_picture(friend.id, :type => "large") }
      end
      pictures.concat(batch_pictures)
    end

    # Zip through the friends and pictures to produce updated Friend
    # objects.
    friends.zip(pictures).collect do |pair|
      friend  = pair.first
      picture = pair.last

      friend.picture = pair.last

      friend
    end
  end
end
