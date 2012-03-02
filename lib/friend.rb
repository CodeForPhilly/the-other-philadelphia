class Friend
  attr_accessor :id
  attr_accessor :name
  attr_accessor :picture
  attr_accessor :tags

  # Public: Instantiates a Friend object
  #
  # attrs - The Hash of Friend attributes (default: {}):
  #         :id       - Facebook user ID
  #         :name     - Facebook user full name
  #         :picture  - Facebook picture URL
  #         :tags     - Tags assigned to this user
  def initialize(attrs = { })
    @id       = attrs[:id] if attrs[:id]
    @name     = attrs[:name] if attrs[:name]
    @picture  = attrs[:picture] if attrs[:picture]
    @tags     = attrs[:tags] || [ ]
  end
end
