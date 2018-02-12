require_relative 'server.rb'

class Runner
  attr_reader :server
  def initialize
    @server = Server.new
    @server.listens
  end

  def responds
    response = "<pre>" + "Hello World (#{@count})" + "</pre>"
    output = "<html><head></head><body>#{response}</body></html>"
    headers = ["http/1.1 200 ok",
          "date: #{Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')}",
          "server: ruby",
          "content-type: text/html; charset=iso-8859-1",
          "content-length: #{output.length}\r\n\r\n"].join("\r\n")
    # @server.client.puts headers
    @server.client.puts response
    @server.client.close
  end
end
