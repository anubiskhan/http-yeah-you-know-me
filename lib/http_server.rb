require 'socket'

class Server
  attr_reader :tcp_server, :client
  def initialize(port)
    @tcp_server = TCPServer.new(port)
    @client = tcp_server.accept
  end
end
