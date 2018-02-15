require './test/test_helper'
require './lib/runner.rb'

class RunnerTest < Minitest::Test
  def test_runner_initializes
    skip
    runner = Runner.new

    assert_instance_of Runner, runner
    assert_instance_of Server, runner.server
  end

  def test_faraday
    connection = Faraday.new('http://127.0.0.1:9292')

    response = connection.get('/hello')
    assert response.include?('Hello')
  end
end
