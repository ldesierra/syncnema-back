class RecommendationsController < ApplicationController
  def show
    user = User.find_by(external_id: params[:user_id])

    return render json: { error: 'User not found' }, status: 404 if user.blank?

    recommendations = Recommender.call(user)

    render json: recommendations, status: 200
  end
end
