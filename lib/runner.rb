require_relative 'server.rb'

class Runner
  attr_reader :server
  def initialize
    @count = 0
    @server = Server.new
    listens
  end

  def listens
    loop do
      session = @server.tcp_server.accept
      session.gets
      @count += 1
      session.puts header(response.length)
      session.puts response
      session.close
      break if @count > 3
    end
  end

  def response
    response = "<pre>" + "Hello World (#{@count})\n" + diagnostics + "</pre>"
    output = "<html><head></head><body>#{response}</body></html>"
  end

  def header(output)
    headers = [
      "http/1.1 200 ok",
      "date: #{Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')}",
      "server: ruby",
      "content-type: text/html; charset=iso-8859-1",
      "content-length: #{output}\r\n\r\n"].join("\r\n")
  end

  def diagnostics
    diag =
      'Verb: POST
      Path: /
      Protocol: HTTP/1.1
      Host: 127.0.0.1
      Port: 9292
      Origin: 127.0.0.1
      Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
  end
end

runner = Runner.new
