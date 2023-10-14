class RatingsController < ApplicationController
  def create
    rating = Rating.new(rating_params)

    if rating.save
      render json: rating, status: 201
    else
      render json: { error: rating.errors }, status: 422
    end
  end

  def update
    rating = Rating.find_by(id: params[:id])

    return render json: { error: 'Rating not found' }, status: 404 unless rating

    if rating.update(score: rating_params[:score])
      render json: rating, status: 200
    else
      render json: { error: rating.errors }, status: 422
    end
  end

  private

  def rating_params
    params.require(:rating).permit(:score, :content_id, :user_id)
  end
end
