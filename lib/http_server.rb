require 'socket'
tcp_server = TCPServer.new(9292)
client = tcp_server.accept
