require './test/test_helper'
require './lib/server.rb'

class ServerTest < Minitest::Test
  def test_server_initializes
    skip
    my_server = Server.new

    assert_instance_of Server, my_server
    assert_instance_of TCPServer, my_server.tcp_server
  end
end
