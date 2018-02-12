require 'minitest/autorun'
require 'minitest/pride'
require './lib/runner.rb'

class RunnerTest < Minitest::Test
  def test_runner_initializes
    runner = Runner.new

    assert_instance_of Runner, runner
    assert_instance_of Server, runner.server
  end
end
