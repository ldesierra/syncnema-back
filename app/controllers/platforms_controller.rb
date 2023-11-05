class PlatformsController < ApplicationController
  def index
    genres = StreamingSite.all.pluck(:name).flatten.uniq

    render json: genres, status: 200
  end
end
