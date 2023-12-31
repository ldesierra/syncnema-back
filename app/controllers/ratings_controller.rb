class RatingsController < ApplicationController
  before_action :load_user

  def create
    rating = Rating.find_or_initialize_by(rating_params.except(:score))

    if rating.update(score: rating_params[:score])
      render json: rating, status: 201
    else
      render json: { error: rating.errors }, status: 422
    end
  end

  def update
    rating = Rating.find_by(content_id: params[:rating][:content_id], user_id: @user.id)

    return render json: { error: 'Rating not found' }, status: 404 unless rating

    if rating.update(rating_params)
      render json: rating, status: 200
    else
      render json: { error: rating.errors }, status: 422
    end
  end

  private

  def load_user
    @user = User.find_by(external_id: params[:rating][:user_id])

    return render json: { error: 'User not found' }, status: 404 if @user.blank?
  end

  def rating_params
    strong_params = params.require(:rating).permit(:score, :content_id, :user_id)

    strong_params = strong_params.merge!(user_id: @user.id)

    strong_params
  end
end
