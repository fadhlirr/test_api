module Api
  module V1
    class UsersController < BaseController
      before_action :set_user, only: [:show, :update, :destroy]

      # GET /api/v1/users
      def index
        @users = Rails.cache.fetch("users/index", expires_in: 5.minutes) do
          User.all.to_a
        end

        render json: @users
      end

      # GET /api/v1/users/1
      def show
        render json: @user
      end

      # POST /api/v1/users
      def create
        @user = User.new(user_params)

        if @user.save
          Rails.cache.delete("users/index")
          render json: @user, status: :created
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/users/1
      def update
        if @user.update(user_params)
          Rails.cache.delete("users/index")
          Rails.cache.delete("users/#{@user.id}")
          render json: @user
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/users/1
      def destroy
        @user.destroy
        Rails.cache.delete("users/index")
        Rails.cache.delete("users/#{@user.id}")
        head :no_content
      end

      private

      def set_user
        user_id = params[:id]

        @user = Rails.cache.fetch("users/#{user_id}", expires_in: 10.minutes) do
          User.find(user_id)
        end
      end

      def user_params
        params.require(:user).permit(:name, :email, :phone)
      end
    end
  end
end
