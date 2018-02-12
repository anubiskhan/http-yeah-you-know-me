require 'socket'

class Server
  attr_reader :server, :client. :request_lines
  def initialize(port)
    @server = TCPServer.new(port)
    @client = server.accept
    @request_lines = []
  end

  def get_request
    @client = @server.gets
  end
end
