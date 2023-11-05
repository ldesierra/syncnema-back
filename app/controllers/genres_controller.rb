class GenresController < ApplicationController
  def index
    genres = Content.all.pluck(:combined_genres).map { |genres| JSON.parse(genres) }.flatten.uniq

    render json: genres, status: 200
  end
end
