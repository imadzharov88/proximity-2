class Hexagon
  Free = -1
  attr_reader :owner_id, :points
  def initialize(owner_id = Free, points = 0)
    @owner_id, @points = owner_id, points
  end
end