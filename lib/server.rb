require 'socket'

class Server
  attr_reader :tcp_server, :client. :request_lines
  def initialize(port)
    @tcp_server = TCPServer.new(port)
    @client = tcp_server.accept
    @request_lines = []
  end

end
