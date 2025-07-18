module Api
  module V1
    class JobsController < BaseController
      before_action :set_job, only: [:show, :update, :destroy]

      # GET /api/v1/jobs
      def index
        if params[:user_id]
          @jobs = Rails.cache.fetch("jobs/index:user_id:#{params[:user_id]}", expires_in: 5.minutes) do
            Job.where(user_id: params[:user_id]).to_a
          end
        else
          @jobs = Rails.cache.fetch("jobs/index", expires_in: 5.minutes) do
            Job.all.to_a
          end
        end
        render json: @jobs
      end

      # GET /api/v1/jobs/1
      def show
        render json: @job
      end

      # POST /api/v1/jobs
      def create
        @job = Job.new(job_params)

        if @job.save
          Rails.cache.delete("jobs/index:user_id:#{@job.user_id}")
          Rails.cache.delete("jobs/index")
          render json: @job, status: :created
        else
          render json: { errors: @job.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/jobs/1
      def update
        if @job.update(job_params)
          Rails.cache.delete("jobs/#{params[:id]}")
          Rails.cache.delete("jobs/index:user_id:#{@job.user_id}")
          Rails.cache.delete("jobs/index")
          render json: @job
        else
          render json: { errors: @job.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/jobs/1
      def destroy
        @job.destroy
        Rails.cache.delete("jobs/#{params[:id]}")
        Rails.cache.delete("jobs/index:user_id:#{@job.user_id}")
        Rails.cache.delete("jobs/index")
        head :no_content
      end

      private

      def set_job
        @job = Rails.cache.fetch("jobs/#{params[:id]}", expires_in: 10.minutes) do
          Job.find(params[:id])
        end
      end

      def job_params
        params.require(:job).permit(:title, :description, :status, :user_id)
      end
    end
  end
end
