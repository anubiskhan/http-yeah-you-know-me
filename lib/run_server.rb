require_relative 'server.rb'

class Runner
  attr_reader :server
  def initialize
    @server = Server.new(9292)
  end

  def listens
    while line = client.gets and !line.chomp.empty?
      request_lines << line.chomp
    end
  end

  def responds
    response = "<pre>" + request_lines.join("\n") + "</pre>"
    output = "<html><head></head><body>#{response}</body></html>"
    headers = ["http/1.1 200 ok",
          "date: #{Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')}",
          "server: ruby",
          "content-type: text/html; charset=iso-8859-1",
          "content-length: #{output.length}\r\n\r\n"].join("\r\n")
    @server.client.puts headers
    @server.client.puts response
  end
end
