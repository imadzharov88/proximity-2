require 'minitest/unit'
require '../game'
require '../player'
require '../hexagon'

class OtherTest < MiniTest::Unit::TestCase
  def test_game
    @game = Game.new 3, 4, [Player.new("Some player", 1), Player.new("Other player", 2)]

    #1
    num = @game.next_num
    @game.claim_hexagon(1, 1)
    assert_equal num, @game.get_at(1, 1).points
    @game.next_move

    #2
    num = @game.next_num
    @game.claim_hexagon(0, 1)
    assert_block { @game.get_at(1, 1).points >= num or @game.get_at(1, 1).owner_id == @game.players.index(@game.next_player) }
    @game.next_move

    #3
    num = @game.next_num
    @game.claim_hexagon(1, 0)
    assert_block { @game.get_at(1, 1).points >= num or @game.get_at(1, 1).owner_id == @game.players.index(@game.next_player) }
    assert_block { @game.get_at(0, 1).points >= num or @game.get_at(0, 1).owner_id == @game.players.index(@game.next_player) }
    @game.next_move

    #4
    num = @game.next_num
    @game.claim_hexagon(0, 0)
    assert_block { @game.get_at(1, 0).points >= num or @game.get_at(1, 0).owner_id == @game.players.index(@game.next_player) }
    assert_block { @game.get_at(0, 1).points >= num or @game.get_at(0, 1).owner_id == @game.players.index(@game.next_player) }
    @game.next_move

    #5
    num = @game.next_num
    @game.claim_hexagon(0, 2)
    assert_block { @game.get_at(1, 1).points >= num or @game.get_at(1, 1).owner_id == @game.players.index(@game.next_player) }
    assert_block { @game.get_at(0, 1).points >= num or @game.get_at(0, 1).owner_id == @game.players.index(@game.next_player) }
    @game.next_move

    #6
    num = @game.next_num
    @game.claim_hexagon(0, 3)
    assert_block { @game.get_at(0, 2).points >= num or @game.get_at(0, 2).owner_id == @game.players.index(@game.next_player) }
    @game.next_move

    #7
    num = @game.next_num
    @game.claim_hexagon(1, 2)
    assert_block { @game.get_at(1, 1).points >= num or @game.get_at(1, 1).owner_id == @game.players.index(@game.next_player) }
    assert_block { @game.get_at(0, 3).points >= num or @game.get_at(0, 3).owner_id == @game.players.index(@game.next_player) }
    assert_block { @game.get_at(0, 2).points >= num or @game.get_at(0, 2).owner_id == @game.players.index(@game.next_player) }
    @game.next_move

    #8
    num = @game.next_num
    @game.claim_hexagon(2, 0)
    assert_block { @game.get_at(1, 0).points >= num or @game.get_at(1, 0).owner_id == @game.players.index(@game.next_player) }
    @game.next_move

    #8
    num = @game.next_num
    @game.claim_hexagon(2, 1)
    assert_block { @game.get_at(1, 0).points >= num or @game.get_at(1, 0).owner_id == @game.players.index(@game.next_player) }
    assert_block { @game.get_at(2, 0).points >= num or @game.get_at(2, 0).owner_id == @game.players.index(@game.next_player) }
    assert_block { @game.get_at(1, 1).points >= num or @game.get_at(1, 1).owner_id == @game.players.index(@game.next_player) }
    @game.next_move

    #10
    num = @game.next_num
    @game.claim_hexagon(2, 2)
    assert_block { @game.get_at(1, 1).points >= num or @game.get_at(1, 1).owner_id == @game.players.index(@game.next_player) }
    assert_block { @game.get_at(1, 2).points >= num or @game.get_at(1, 2).owner_id == @game.players.index(@game.next_player) }
    assert_block { @game.get_at(2, 1).points >= num or @game.get_at(2, 1).owner_id == @game.players.index(@game.next_player) }
    @game.next_move

    #11
    num = @game.next_num
    @game.claim_hexagon(2, 3)
    assert_block { @game.get_at(2, 2).points >= num or @game.get_at(2, 2).owner_id == @game.players.index(@game.next_player) }
    assert_block { @game.get_at(1, 2).points >= num or @game.get_at(1, 2).owner_id == @game.players.index(@game.next_player) }
    @game.next_move

    #12
    num = @game.next_num
    @game.claim_hexagon(1, 3)
    assert_block { @game.get_at(0, 3).points >= num or @game.get_at(0, 3).owner_id == @game.players.index(@game.next_player) }
    assert_block { @game.get_at(2, 3).points >= num or @game.get_at(2, 3).owner_id == @game.players.index(@game.next_player) }
    assert_block { @game.get_at(1, 2).points >= num or @game.get_at(1, 2).owner_id == @game.players.index(@game.next_player) }

    assert @game.game_over?
  end
end