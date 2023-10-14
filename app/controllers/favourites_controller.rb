class FavouritesController < ApplicationController
  def create
    favourite = Favourite.new(favourite_params)

    if favourite.save
      render json: favourite, status: 201
    else
      render json: { error: favourite.errors }, status: 422
    end
  end

  def destroy
    favourite = Favourite.find_by(id: params[:id])

    return render json: { error: 'Favourite not found' }, status: 404 unless favourite

    if favourite.destroy
      render json: { message: 'Favourite removed' }, status: 200
    end
  end

  private

  def favourite_params
    params.require(:favourite).permit(:content_id, :user_id)
  end
end
