class UsersController < ApplicationController
  def create
    user = User.new(user_params)

    if user.save
      render json: user, status: 201
    else
      render json: { errors: user.errors }, status: 422
    end
  end

  def destroy
    user = User.find_by(external_id: params[:id])

    render json: { errors: 'User not found' }, status: 404 and return unless user

    user.destroy
    render json: {}, status: 204
  end

  private

  def user_params
    params.require(:user).permit(:email, :external_id)
  end
end
