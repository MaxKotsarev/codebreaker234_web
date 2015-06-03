require "erb"
require 'yaml'
require 'date'
require 'codebreaker234'
 
class WebUiController  
  def self.call(env)
    new(env).response.finish
  end
   
  def initialize(env)
    @request = Rack::Request.new(env)
    @current_game_file = "current_game.txt"
    @saved_results_file = "saved_results.txt"
  end

  def render(template)
    path = File.expand_path("../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end
   
  def response
    game = current_game 
    case @request.path
    when "/" then Rack::Response.new(render("index.html.erb"))
    when "/submit_guess"
      Rack::Response.new do |response|
        game.analize(@request.params["guess"])
        game.save_to(@current_game_file) 
        response.redirect("/")
      end
    when "/new_game" 
      Rack::Response.new do |response|
        start_new_game
        response.redirect("/")
      end
    when "/hint" 
      Rack::Response.new do |response|
        game.user_guesses_and_answers << {"hint" => game.hint}
        game.save_to(@current_game_file)
        response.redirect("/")
      end   
    when "/save_result" 
      Rack::Response.new do |response|
        user_name = @request.params["name"].size > 0 ? @request.params["name"] : "Anonimus Player" 
        results = saved_results
        results.results << {name: user_name, score: game.score, date: Time.now}
        results.results = results.results.sort_by{ |k| k[:score] }.reverse
        results.save_to(@saved_results_file)
        game.result_saved = true
        game.save_to(@current_game_file)
        response.redirect("/")
      end
    else Rack::Response.new("Not Found", 404)
    end
  end

  def current_game 
    if File.exist?(@current_game_file)
      Codebreaker234::Game.load_from(@current_game_file)
    else
      start_new_game
    end
  end

  def start_new_game
    game = Codebreaker234::Game.new
    game.start
    game.save_to(@current_game_file)
  end
   
  def saved_results 
    if File.exist?(@saved_results_file)
      Codebreaker234::ResultsCollection.load_from(@saved_results_file)
    else
      resuts = Codebreaker234::ResultsCollection.new
      resuts.save_to(@saved_results_file)
    end
  end
   
  def game
    current_game
  end
end


