require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :request do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }

  let(:valid_attributes) do
    {
      name: "John Doe",
      email: "john@example.com",
      phone: "08123456789"
    }
  end

  let(:invalid_attributes) do
    {
      name: "",
      email: "",
      phone: ""
    }
  end

  describe "GET /api/v1/users" do
    it "returns all users with cache" do
      Rails.cache.clear
      get "/api/v1/users"
      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)
      expect(data.size).to eq(User.count)
    end
  end

  describe "GET /api/v1/users/:id" do
    it "returns the user with cache" do
      Rails.cache.clear
      get "/api/v1/users/#{user.id}"
      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)
      expect(data["id"]).to eq(user.id)
    end
  end

  describe "POST /api/v1/users" do
    context "with valid params" do
      it "creates a new user and invalidates index cache" do
        Rails.cache.write("users/index", [user])
        expect {
          post "/api/v1/users", params: { user: valid_attributes }
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(Rails.cache.read("users/index")).to be_nil
      end
    end

    context "with invalid params" do
      it "does not create user and returns errors" do
        expect {
          post "/api/v1/users", params: { user: invalid_attributes }
        }.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to have_key("errors")
      end
    end
  end

  describe "PATCH /api/v1/users/:id" do
    it "updates user and clears cache" do
      Rails.cache.write("users/index", [user])
      Rails.cache.write("users/#{user.id}", user)

      patch "/api/v1/users/#{user.id}", params: { user: { name: "Updated Name" } }
      expect(response).to have_http_status(:ok)
      expect(user.reload.name).to eq("Updated Name")
      expect(Rails.cache.read("users/index")).to be_nil
      expect(Rails.cache.read("users/#{user.id}")).to be_nil
    end

    it "fails to update with invalid data" do
      patch "/api/v1/users/#{user.id}", params: { user: { email: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /api/v1/users/:id" do
    it "deletes user and clears cache" do
      Rails.cache.write("users/index", [user, other_user])
      Rails.cache.write("users/#{user.id}", user)

      expect {
        delete "/api/v1/users/#{user.id}"
      }.to change(User, :count).by(-1)

      expect(response).to have_http_status(:no_content)
      expect(Rails.cache.read("users/index")).to be_nil
      expect(Rails.cache.read("users/#{user.id}")).to be_nil
    end
  end
end
