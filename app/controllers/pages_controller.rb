require 'open-uri'
require 'json'

class PagesController < ApplicationController

  def grid
  end

  def game
    @size = params[:size].to_i
    @grid = generate_grid(@size)
    @start_time = Time.now
  end

  def score
    @end_time = Time.now
    @start_time = params[:start_time].to_time
    @attempt = params[:attempt]
    @grid = params[:grid]
    @result = run_game(@attempt, @grid, @start_time, @end_time)
  end

  def generate_grid(grid_size)
    Array.new(grid_size) { ('A'..'Z').to_a[rand(26)] }
  end

  def run_game(attempt, grid, start_time, end_time)
    result = {}
    result[:time] = end_time - start_time
    result[:translation] = get_translation(attempt)
    result[:score], result[:message] = score_and_message(attempt, result[:translation], grid, result[:time])
    result
  end

  def included?(attempt, grid)
    the_grid = grid.clone.split("")
    attempt.chars.each do |letter|
      the_grid.delete_at(the_grid.index(letter)) if the_grid.include?(letter)
    end
    grid.size == attempt.size + the_grid.size
  end

  def compute_score(attempt, time_taken)
    (time_taken > 60.0) ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end


  def score_and_message(attempt, translation, grid, time)
    if translation
      if included?(attempt.upcase, grid)
        score = compute_score(attempt, time)
        [score, "well done"]
      else
        [0, "not in the grid"]
      end
    else
      [0, "not an english word"]
    end
  end

  def get_translation(word)
    response = open("http://api.wordreference.com/0.8/80143/json/enfr/#{word.downcase}")
    json = JSON.parse(response.read.to_s)
    json['term0']['PrincipalTranslations']['0']['FirstTranslation']['term'] unless json["Error"]
  end

end
