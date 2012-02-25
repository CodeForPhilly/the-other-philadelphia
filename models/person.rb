class Person
  attr_reader :name
  attr_reader :picture
  attr_reader :tags

  def initialize(name, picture, tags)
    @name = name
    @picture = picture
    @tags = tags
  end

  def inspect
    { :name => @name, :picture => @picture, :tags => @tags }
  end
end
