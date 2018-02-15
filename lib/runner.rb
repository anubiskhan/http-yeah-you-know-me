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
      request(session)
      session.puts header(@resp.length)
      session.puts @resp
      session.close
      break if @resp.include?('Total Requests:')
    end
  end

  def path(request)
    request[0].split[1]
  end

  def response(request)
    return root_response(request) if path(request) == '/'
    return hello_response(request) if path(request) == '/hello'
    return datetime_response(request) if path(request) == '/datetime'
    return shutdown_response(request) if path(request) == '/shutdown'
  end

  def header(output)
    headers = [
      "http/1.1 200 ok",
      "date: #{Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')}",
      "server: ruby",
      "content-type: text/html; charset=iso-8859-1",
      "content-length: #{output}\r\n\r\n"].join("\r\n")
  end


  def request(session)
    request = []
    while line = session.gets and !line.chomp.empty?
      request << line.chomp
    end
    @count += 1
    puts request.inspect
    @resp = response(request)
  end

  def root_response(request)
    response = "<pre> #{parser(request)} </pre>"
    "<html><head></head><body>#{response}</body></html>"
  end

  def hello_response(request)
    response = "<pre> Hello World (#{@hello_count})\n #{parser(request)} </pre>"
    @hello_count += 1
    "<html><head></head><body>#{response}</body></html>"
  end

  def datetime_response(request)
    response = "<pre> #{Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')}\n #{parser(request)} </pre>"
    "<html><head></head><body>#{response}</body></html>"
  end

  def shutdown_response(request)
    response = "<pre> Total Requests: (#{@count})\n #{parser(request)} </pre>"
    "<html><head></head><body>#{response}</body></html>"
  end

  def parser(request)
    @vpp = request.shift
    @host = request.shift
    @info = {}
    request.each do |spec|
      spec = spec.split if spec.include?(':')
      @info[spec[0]] = spec[1]
    end
    diagnostic
  end

  def diagnostic
    "Verb: #{@vpp.split[0]}
    Path: #{@vpp.split[1]}
    Protocol: #{@vpp.split[2]}
    Host: #{@host.split[1].split(':')[0]}
    Port: #{@host.split[1].split(':')[1]}
    Origin: #{@host.split[1].split(':')[0]}
    Accept: #{@info['Accept:']}"
  end
end

runner = Runner.new
