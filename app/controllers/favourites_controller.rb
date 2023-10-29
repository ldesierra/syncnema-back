class FavouritesController < ApplicationController
  before_action :load_user

  def index
    favourites = Favourite.where(user_id: @user.id)
                          .joins(:content)
                          .select('contents.title, contents.image_url, contents.type, contents.id')

    splitted_favourites = favourites.group_by { |favourite| favourite[:type] }

    response = { movies: splitted_favourites['Movie'], series: splitted_favourites['Serie'] }
    render json: response, status: 200
  end

  def create
    favourite = Favourite.find_or_initialize_by(favourite_params)

    if favourite.save
      render json: favourite, status: 201
    else
      render json: { error: favourite.errors }, status: 422
    end
  end

  def destroy
    favourite = Favourite.find_by(content_id: params[:content_id], user_id: @user.id)

    return render json: { error: 'Favourite not found' }, status: 404 unless favourite

    if favourite.destroy
      render json: { message: 'Favourite removed' }, status: 200
    end
  end

  private

  def load_user
    user_id = params[:user_id] || params[:favourite][:user_id]
    @user = User.find_by(external_id: user_id)

    render json: { error: 'User not found' }, status: 404 if @user.blank?
  end

  def favourite_params
    strong_params = params.require(:favourite).permit(:content_id, :user_id)
    strong_params = strong_params.merge!(user_id: @user.id)

    strong_params
  end
end
