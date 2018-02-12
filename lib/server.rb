require 'socket'

class Server
  attr_reader :tcp_server
  def initialize
    @tcp_server = TCPServer.new(9292)
    @count = 0
  end

  def listens
    loop do
      session = server.accept
      session.puts "Hello World (#{@count})"
      @count += 1
      session.close
    end
  end
end
