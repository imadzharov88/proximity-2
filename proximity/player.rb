class Player
  attr_reader :name, :color
  attr_accessor :points
  def initialize(name, color)
    @name, @color = name, color
    @points = 0
  end
end