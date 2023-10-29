class RecommendationsController < ApplicationController
  def show
    user = User.find_by(external_id: params[:user_id])

    render json: get_generic_recommendations, status: 200 and return if user.blank?

    recommendations = Recommender.call(user)
    recommendations = get_generic_recommendations if recommendations.blank?

    render json: recommendations, status: 200
  end

  private
  def get_generic_recommendations
    Content.order(rating: :desc).limit(10)
  end

end
