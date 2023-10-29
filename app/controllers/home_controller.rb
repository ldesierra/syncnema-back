class HomeController < ApplicationController

  def index
    limit = params[:limit] || 10

    movies = Movie.select(:id, :title, :image_url).order(rating: :desc).limit(limit)

    series = Serie.select(:id, :title, :image_url).order(rating: :desc).limit(limit)

    render json: { movies: movies, series: series }, status: 200
  end

end
