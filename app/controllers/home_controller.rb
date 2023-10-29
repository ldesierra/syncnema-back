class HomeController < ApplicationController

  def index
    @limit = params[:limit] || 10

    movies = Movie.select(:id, :title, :image_url).order(rating: :desc).limit(@limit)
    series = Serie.select(:id, :title, :image_url).order(rating: :desc).limit(@limit)

    response = { movies: movies, series: series, recommendations: get_recommendations }
    render json: response, status: 200
  end

  private

  def get_recommendations
    user = User.find_by(external_id: params[:user_id])

    return get_generic_recommendations if user.blank?

    recommendations = Recommender.call(user)
    recommendations = get_generic_recommendations if recommendations.blank?

    return recommendations
  end

  def get_generic_recommendations
    recommendations = Content.select(:id, :title, :image_url, :type)
                              .order(rating: :desc)
                              .limit(@limit)

    recommendations.map { |r| r.attributes.merge({ type: r.type }) }
  end

end
