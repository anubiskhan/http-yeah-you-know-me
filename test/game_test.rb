require './test/test_helper'
require './lib/game.rb'

class GameTest < Minitest::Test
  def test_game_initializes_properly
    game = Game.new

    assert_instance_of Game, game
    assert_equal 0, game.attempts
    assert game.the_number >= 1 && game.the_number <= 100
  end

  def test_guessing_works
    game = Game.new
    num = game.the_number

    assert_equal '0. Too low!', game.post_game(0)
    assert_equal 1, game.guesses.length
    assert_equal '101. Too high!', game.post_game(101)
    assert_equal 2, game.guesses.length
    assert_equal "#{num}. Correct!", game.post_game(num)
  end

  def test_getting_game_works
    game = Game.new
    game.post_game(0)
    game.post_game(101)
    expected = 'There have been 2 and those guesses were ["0. Too low!", "101. Too high!"]'
    assert_equal expected, game.get_game
  end
end
