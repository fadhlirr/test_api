require 'rails_helper'

RSpec.describe Api::V1::JobsController, type: :request do
  let!(:user) { create(:user) }
  let!(:job1) { create(:job, user: user) }
  let!(:job2) { create(:job, user: user) }

  let(:valid_attributes) do
    {
      title: "New Job",
      description: "Something important",
      status: "pending",
      user_id: user.id
    }
  end

  let(:invalid_attributes) do
    {
      title: "",
      description: "",
      status: "",
      user_id: nil
    }
  end

  describe "GET /api/v1/jobs" do
    it "returns all jobs with cache" do
      Rails.cache.clear
      get "/api/v1/jobs"
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(Job.count)
    end

    it "returns jobs filtered by user_id with cache" do
      Rails.cache.clear
      get "/api/v1/jobs", params: { user_id: user.id }
      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)
      expect(data.size).to eq(2)
      expect(data.map { |j| j["user_id"] }.uniq).to eq([user.id])
    end
  end

  describe "GET /api/v1/jobs/:id" do
    it "returns a specific job with cache" do
      Rails.cache.clear
      get "/api/v1/jobs/#{job1.id}"
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["id"]).to eq(job1.id)
    end
  end

  describe "POST /api/v1/jobs" do
    context "with valid params" do
      it "creates a new job and invalidates caches" do
        Rails.cache.write("jobs/index", [job1, job2])
        Rails.cache.write("jobs/index:user_id:#{user.id}", [job1, job2])

        expect {
          post "/api/v1/jobs", params: { job: valid_attributes }
        }.to change(Job, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(Rails.cache.read("jobs/index")).to be_nil
        expect(Rails.cache.read("jobs/index:user_id:#{user.id}")).to be_nil
      end
    end

    context "with invalid params" do
      it "does not create a job and returns errors" do
        expect {
          post "/api/v1/jobs", params: { job: invalid_attributes }
        }.not_to change(Job, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to have_key("errors")
      end
    end
  end

  describe "PATCH /api/v1/jobs/:id" do
    it "updates job and invalidates related caches" do
      Rails.cache.write("jobs/#{job1.id}", job1)
      Rails.cache.write("jobs/index", [job1])
      Rails.cache.write("jobs/index:user_id:#{user.id}", [job1])

      patch "/api/v1/jobs/#{job1.id}", params: { job: { title: "Updated Title" } }
      expect(response).to have_http_status(:ok)
      expect(job1.reload.title).to eq("Updated Title")
      expect(Rails.cache.read("jobs/#{job1.id}")).to be_nil
      expect(Rails.cache.read("jobs/index")).to be_nil
      expect(Rails.cache.read("jobs/index:user_id:#{user.id}")).to be_nil
    end

    it "returns errors with invalid params" do
      patch "/api/v1/jobs/#{job1.id}", params: { job: { title: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /api/v1/jobs/:id" do
    it "deletes the job and clears related caches" do
      Rails.cache.write("jobs/#{job1.id}", job1)
      Rails.cache.write("jobs/index", [job1, job2])
      Rails.cache.write("jobs/index:user_id:#{user.id}", [job1, job2])

      expect {
        delete "/api/v1/jobs/#{job1.id}"
      }.to change(Job, :count).by(-1)

      expect(response).to have_http_status(:no_content)
      expect(Rails.cache.read("jobs/#{job1.id}")).to be_nil
      expect(Rails.cache.read("jobs/index")).to be_nil
      expect(Rails.cache.read("jobs/index:user_id:#{user.id}")).to be_nil
    end
  end
end
