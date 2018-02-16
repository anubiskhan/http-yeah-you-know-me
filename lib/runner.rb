require './lib/server.rb'
require './lib/game.rb'
require 'pry'

class Runner
  attr_reader :server
  def initialize
    @count = 0
    @hello_count = 0
    @server = Server.new
    @status = '200 ok'
    @redirect_path = nil
    listens
  end

  def listens
    loop do
      @session = @server.tcp_server.accept
      request(@session)
      @session.puts header(@resp.length)
      @session.puts @resp
      binding.pry
      @session.close
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
    return word_search(request) if path(request).include? '/word_search'
    return game_time(request) if path(request).include? '/game'
    if path(request).include? '/start_game'
      if @vpp.split[0] == 'POST'
        start_game(request)
      else
        "<html><head></head><body> Did you mean to POST to /start_game? </body></html>"
      end
    end
  end

  def request(session)
    request = []
    while line = session.gets and !line.chomp.empty?
      request << line.chomp
    end
    parser(request)
    @count += 1
    # puts request.inspect
    @resp = response(request)
  end

  def root_response(request)
    response = "<pre> #{diagnostic} </pre>"
    "<html><head></head><body>#{response}</body></html>"
  end

  def hello_response(request)
    response = "<pre> Hello World (#{@hello_count})\n #{diagnostic} </pre>"
    @hello_count += 1
    "<html><head></head><body>#{response}</body></html>"
  end

  def datetime_response(request)
    response = "<pre> #{Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')}\n #{diagnostic} </pre>"
    "<html><head></head><body>#{response}</body></html>"
  end

  def shutdown_response(request)
    response = "<pre> Total Requests: (#{@count})\n #{diagnostic} </pre>"
    "<html><head></head><body>#{response}</body></html>"
  end

  def word_search(request)
    word = request[0].split[1].split('?')[1].downcase
    if File.read('/usr/share/dict/words').split.include?(word)
      is_word = "#{word} is a known word"
    else
      is_word = "#{word} is not a known word"
    end
    response = "<pre> #{is_word}\n #{diagnostic} </pre>"
    "<html><head></head><body>#{response}</body></html>"
  end

  def start_game(request)
    @game = Game.new
    response = "<pre> Good luck!\n #{diagnostic} </pre>"
    "<html><head></head><body>#{response}</body></html>"
  end

  def game_time(request)
    if request[0].split[0] == 'POST'
      @content_length = @info['Content-Length:'].to_i
      @guess = @session.read(@content_length).split[-2].to_i
      response = "<pre> #{@game.post_game(@guess)}\n #{diagnostic} </pre>"
    elsif request[0].split[0] == 'GET'
      response = "<pre> #{@game.get_game}\n #{diagnostic} </pre>"
    end
    "<html><head></head><body>#{response}</body></html>"
  end

  def parser(request)
    @vpp = request[0]
    @host = request[1]
    @info = {}
    request.each do |spec|
      spec = spec.split if spec.include?(':')
      @info[spec[0]] = spec[1]
    end
  end

  def header(length)
    headers = [
      "http/1.1 200 ok",
      "date: #{Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')}",
      "server: ruby",
      "content-type: text/html; charset=iso-8859-1",
      "content-length: #{length}\r\n\r\n"].join("\r\n")
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
