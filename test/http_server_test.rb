require 'minitest/autorun'
require 'minitest/pride'
require './lib/http_server.rb'

class ServerTest < Minitest::Test
  def test_server_initializes
    my_server = Server.new(9292)

    assert_instance_of Server, my_server
    assert_instance_of TCPServer, my_server.tcp_server
  end
end
