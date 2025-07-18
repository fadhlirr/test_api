require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :request do
  let!(:user) { FactoryBot.create(:user) }

  let(:valid_attributes) do
    {
      name: "Jane Doe",
      email: "jane.doe@example.com",
      phone: "08123456789"
    }
  end

  let(:invalid_attributes) do
    {
      name: "",                 # name is required
      email: "invalid-email",   # invalid email format
      phone: ""                 # phone is required
    }
  end

  describe "GET /api/v1/users" do
    it "returns a list of users" do
      get "/api/v1/users"

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)
      expect(data).to be_an(Array)
      expect(data.first).to include("id", "name", "email", "phone")
    end
  end

  describe "GET /api/v1/users/:id" do
    it "returns the requested user" do
      get "/api/v1/users/#{user.id}"

      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)
      expect(data['id']).to eq(user.id)
      expect(data['email']).to eq(user.email)
    end
  end

  describe "POST /api/v1/users" do
    context "with valid params" do
      it "creates a new user" do
        expect {
          post "/api/v1/users", params: { user: valid_attributes }
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:created)
      end
    end

    context "with invalid params" do
      it "does not create a user" do
        expect {
          post "/api/v1/users", params: { user: invalid_attributes }
        }.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to have_key("errors")
      end
    end
  end

  describe "PATCH /api/v1/users/:id" do
    context "with valid params" do
      it "updates the user" do
        patch "/api/v1/users/#{user.id}", params: { user: { name: "Updated Name" } }

        expect(response).to have_http_status(:ok)
        expect(user.reload.name).to eq("Updated Name")
      end
    end

    context "with invalid params" do
      it "does not update the user" do
        patch "/api/v1/users/#{user.id}", params: { user: { email: "" } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to have_key("errors")
      end
    end
  end

  describe "DELETE /api/v1/users/:id" do
    it "deletes the user" do
      expect {
        delete "/api/v1/users/#{user.id}"
      }.to change(User, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
