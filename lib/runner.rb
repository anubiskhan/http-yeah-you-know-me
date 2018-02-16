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
    return error_response(request) if path(request) == '/force_error'
    return game_time(request) if path(request) == '/game'
    return handle_post_game(request) if path(request).include? '/start_game'
    not_found(request)
  end

  def request(session)
    request = []
    while line = session.gets and !line.chomp.empty?
      request << line.chomp
    end
    parser(request)
    @count += 1
    puts request.inspect
    @resp = response(request)
  end

  def root_response(_request)
    response = "<pre> #{diagnostic} </pre>"
    "<html><head></head><body>#{response}</body></html>"
  end

  def hello_response(_request)
    response = "<pre> Hello World (#{@hello_count})\n #{diagnostic} </pre>"
    @hello_count += 1
    "<html><head></head><body>#{response}</body></html>"
  end

  def datetime_response(_request)
    response = "<pre> #{Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')}\n #{diagnostic} </pre>"
    "<html><head></head><body>#{response}</body></html>"
  end

  def shutdown_response(_request)
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

  def handle_post_game(request)
    if @vpp.split[0] == 'POST'
      start_game(request)
    else
      '<html><head></head><body> Did you mean to POST to /start_game? </body></html>'
    end
  end

  def error_response(_request)
    redirect500
    "<pre> #{@status}\n </pre>"
  end

  def not_found(_request)
    redirect404
    "<pre> #{@status} </pre>"
  end

  def start_game(_request)
    if @game.nil?
      redirect301
      @game = Game.new
      response = "<pre>\n #{@status}\n Good luck!\n #{diagnostic} </pre>"
    else
      redirect403
      response = "<pre> #{@status}\n #{diagnostic} </pre>"
    end
    "<html><head></head><body>#{response}</body></html>"
  end

  def game_time(request)
    if request[0].split[0] == 'POST'
      redirect302
      @content_length = @info['Content-Length:'].to_i
      @guess = @session.read(@content_length).split[-2].to_i
      response = "<pre> #{@game.post_game(@guess)}\n #{diagnostic} </pre>"
    elsif request[0].split[0] == 'GET'
      redirect200
      response = "<pre> #{@game.game_getter}\n #{diagnostic} </pre>"
    end
    "<html><head></head><body>#{response}</body></html>"
  end

  def redirect200
    @status = '200 ok'
    @location = nil
  end

  def redirect301
    @status = '301 Moved Permanently'
    @redirect_path = nil
  end

  def redirect302
    @status = '302'
    @redirect_path = '/game'
  end

  def redirect403
    @status = '403 Forbidden'
    @redirect_path = nil
  end

  def redirect404
    @status = '404 Not Found'
    @location = nil
  end

  def redirect500
    @status = '500 Internal Server Error'
    @location = nil
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
    [ "http/1.1 #{@status}",
      "Location: #{@redirect_path}",
      "date: #{Time.now.strftime('%a, %e %b %Y %H:%M:%S %z')}",
      'server: ruby',
      'content-type: text/html; charset=iso-8859-1',
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

Runner.new
