require_relative './hexagon'#Shoes made me do this...

class Game
  attr_reader :rows, :columns, :players, :next_num, :next_player
  def initialize(rows, columns, players)
    @rows, @columns, @players = rows, columns, players

    @hexagons = Array.new(@rows){ Array.new(@columns){ Hexagon.new } }
    @next_player_idx = -1
    @claimed_count = 0
    next_move
  end

  def next_move
    @next_num = 2 + rand(19)#shoes can't deal with ranges!
    @next_player_idx += 1
    @next_player = @players[@next_player_idx]
    if @next_player == nil
      @next_player_idx = 0
      @next_player = @players[@next_player_idx]
    end
  end

  #returns list of changed hexagons
  def claim_hexagon(row, col)
    return unless @hexagons[row][col].owner_id == Hexagon::Free
    @hexagons[row][col] = Hexagon.new(@next_player_idx, @next_num)
    result = [{ row: row, col: col }]

    #measure all the surrounding hexagons
    if row % 2 == 0
      neighbors = [[row - 1, col - 1], [row - 1, col], [row, col - 1], [row, col + 1], [row + 1, col - 1], [row + 1, col]]
    else
      neighbors = [[row - 1, col], [row - 1, col + 1], [row, col - 1], [row, col + 1], [row + 1, col], [row + 1, col + 1]]
    end
    neighbors.each do |item|
      if item[0] >= 0 and item[0] < @rows and item[1] >= 0 and item[1] < @columns
        hex = @hexagons[item[0]][item[1]]
        if hex != nil and hex.owner_id != Hexagon::Free
          result.push({ row: item[0], col: item[1] })
          if hex.owner_id == @next_player_idx
            @hexagons[item[0]][item[1]] = Hexagon.new(@next_player_idx, calc_increased_points(hex.points))
          else
            if @next_num > hex.points
              @hexagons[item[0]][item[1]] = Hexagon.new(@next_player_idx, hex.points)
            end
          end
        end
      end
    end
    recalculate_points
    @claimed_count += 1
    return result
  end

  def get_at(row, col)
    begin
      return @hexagons[row][col]
    rescue NoMethodError => ex
      return nil
    end
  end

  def game_over?
    return @claimed_count >= @rows * @columns
  end

  def get_winner
    return @players.sort{|one, two| one.points <=> two.points }.pop
  end

  private

  def calc_increased_points(points)
    return points + 1 <= 20 ? points + 1 : points
  end

  def recalculate_points
    @players.each do |player|
      player.points = 0
    end
    @hexagons.each do |row|
      row.each do |hex|
        if hex.owner_id != Hexagon::Free
          @players[hex.owner_id].points += hex.points
        end
      end
    end
  end
end

#require_relative './player'
#g = Game.new(3, 3, [Player.new('aaa', 123), Player.new('bbb', 123456)])
#g.claim_hexagon(2, 2)
#g.next_move
#g.claim_hexagon(2, 1)
#g.next_move
#g.claim_hexagon(1, 1)
#g.next_move