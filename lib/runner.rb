require './lib/server.rb'
require 'pry'

class Runner
  attr_reader :server
  def initialize
    @count = 0
    @hello_count = 0
    @server = Server.new
    listens
  end

  def listens
    loop do
      session = @server.tcp_server.accept
      request = []
      while line = session.gets and !line.chomp.empty?
        request << line.chomp
      end
      @count += 1
      puts request.inspect
      session.puts header(response(request).length)
      session.puts response(request)
      session.close
      # break if @count > 3
    end
  end

  def response(request)
    if request[0].split[1] == '/'
      response = "<pre>" + diagnostics(request) + "</pre>"
    elsif request[0].split[1] == '/hello'
      @hello_count += 1
      #count is doubling because of lines 22/23 double call
      response = "<pre>" + "Hello World (#{@hello_count/2})\n" + "</pre>"
    elsif request[0].split[1] == '/datetime'
      response = "<pre>" + "#{Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')}\n" + "</pre>"
    elsif request[0].split[1] == '/shutdown'
      response = "<pre>" + "Total Requests: (#{@count})\n" + "</pre>"
      
    end
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

  def diagnostics(request)
    #Needs to take the parts from request array and appropriately place them
    diag =
      "Verb: #{request[0].split[0]}
      Path: #{request[0].split[1]}
      Protocol: #{request[0].split[2]}
      Host: #{request[1].split[1].split(':')[0]}
      Port: #{request[1].split[1].split(':')[1]}
      Origin: #{request[1].split[1].split(':')[0]}
      Accept: #{request[6].split[1]}"
  end
end

runner = Runner.new
