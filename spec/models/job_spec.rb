require 'rails_helper'

RSpec.describe Job, type: :model do
  let(:user) { FactoryBot.create(:user) }
  let(:valid_attributes) do
    {
      title: "Software Engineer",
      description: "Full-time position for Ruby developer",
      status: "pending",
      user: user
    }
  end

  describe "validations" do
    it "is valid with valid attributes" do
      job = Job.new(valid_attributes)
      expect(job).to be_valid
    end

    it "is not valid without a title" do
      job = Job.new(valid_attributes.merge(title: nil))
      expect(job).not_to be_valid
      expect(job.errors[:title]).to include("can't be blank")
    end

    it "is not valid without a description" do
      job = Job.new(valid_attributes.merge(description: nil))
      expect(job).not_to be_valid
      expect(job.errors[:description]).to include("can't be blank")
    end

    it "is not valid without a status" do
      job = Job.new(valid_attributes.merge(status: nil))
      expect(job).not_to be_valid
      expect(job.errors[:status]).to include("can't be blank")
    end

    it "is not valid with an invalid status" do
      job = Job.new(valid_attributes.merge(status: "invalid_status"))
      expect(job).not_to be_valid
      expect(job.errors[:status]).to include("is not included in the list")
    end
  end

  describe "associations" do
    it "belongs to a user" do
      expect(Job.reflect_on_association(:user).macro).to eq :belongs_to
    end
  end

  describe "status values" do
    it "allows pending status" do
      job = Job.new(valid_attributes.merge(status: "pending"))
      expect(job).to be_valid
    end

    it "allows in_progress status" do
      job = Job.new(valid_attributes.merge(status: "in_progress"))
      expect(job).to be_valid
    end

    it "allows completed status" do
      job = Job.new(valid_attributes.merge(status: "completed"))
      expect(job).to be_valid
    end
  end
end
