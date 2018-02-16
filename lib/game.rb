# require './lib/runner.rb'

class Game
  attr_reader :the_number, :attempts, :guesses
  def initialize
    @attempts = 0
    @the_number = rand(1..100)
    @guesses = []
  end

  def post_game(guess)
    thing =  "#{guess}. Correct!" if guess == @the_number
    thing = "#{guess}. Too low!" if guess < @the_number
    thing = "#{guess}. Too high!" if guess > @the_number
    @guesses.push(thing)
    thing
  end

  def game_getter
    "There have been #{@guesses.length} and those guesses were #{@guesses}"
  end
end
