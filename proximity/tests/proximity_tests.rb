require 'minitest/unit'
require '../game'
require '../player'
require '../hexagon'

class ProximityTest < MiniTest::Unit::TestCase
  def test_game
    @game = Game.new 3, 4, [Player.new("Some player", 1), Player.new("Other player", 2)]

    @game.rows.times do |row|
      @game.columns.times do |col|
        assert_block { @game.next_num >= 2 and @game.next_num <= 20 }
        assert_block { @game.players.index(@game.next_player) != nil }

        if row % 2 == 0
          neighbors = [[row - 1, col - 1], [row - 1, col], [row, col - 1], [row, col + 1], [row + 1, col - 1], [row + 1, col]]
        else
          neighbors = [[row - 1, col], [row - 1, col + 1], [row, col - 1], [row, col + 1], [row + 1, col], [row + 1, col + 1]]
        end

        valid = neighbors.find_all {|item| item[0] >= 0 and item[0] < @game.rows and item[1] >= 0 and item[1] < @game.columns }
        before_claim = valid.map {|item| @game.get_at(item[0], item[1]) }
        before_claim = before_claim.find_all {|hex| hex.owner_id != Hexagon::Free }
        
        selected_hex = @game.get_at(row, col)
        before_claim.unshift(selected_hex)
        
        assert_block { selected_hex.owner_id == Hexagon::Free }
        after_claim = @game.claim_hexagon(row, col)
        
        assert_equal before_claim.length, after_claim.length
        
        assert_block do
          changed = before_claim.map do |hex|
            if @game.players[hex.owner_id] == @game.next_player
              Hexagon.new hex.owner_id, hex.points + 1
            else
              if @game.next_num > hex.points
                Hexagon.new @game.players.index(@game.next_player), @game.next_num
              else
                hex
              end
            end
          end
          after_claim.map! {|hex| @game.get_at hex.fetch(:row), hex.fetch(:col) }
          
          #p "#{changed} - #{after_claim}"
          
          result = true
          
          changed.each_with_index do |item, index|
            if item.owner_id != after_claim[index].owner_id or item.points != after_claim[index].points
              result = false
            end
          end
          
          p "#{changed} - #{after_claim}"
          p result
          result
        end
        
        @game.next_move
      end
    end
    assert @game.game_over?
    assert_block { @game.players.all? {|player| player.points <= @game.get_winner.points }}
  end
end