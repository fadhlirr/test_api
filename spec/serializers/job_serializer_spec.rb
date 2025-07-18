require 'rails_helper'

RSpec.describe JobSerializer do
  describe 'serialization' do
    let(:user) { FactoryBot.create(:user, name: "John Doe", email: "john@example.com") }
    let(:job) do
      FactoryBot.create(
        :job,
        title: "Senior Developer",
        description: "Builds software",
        status: "pending",
        user: user
      )
    end

    subject { described_class.new(job) }
    let(:serialization) { ActiveModelSerializers::Adapter.create(subject) }
    let(:serialized_data) { JSON.parse(serialization.to_json) }

    it 'includes the correct job attributes' do
      data = serialized_data
      expect(data).to include(
        'id' => job.id,
        'title' => job.title,
        'description' => job.description,
        'status' => job.status,
        'user_id' => user.id,
        'created_at' => job.created_at.as_json,
        'updated_at' => job.updated_at.as_json
      )
    end

    it 'includes the associated user' do
      data = serialized_data
      expect(data['user']).to include(
        'id' => user.id,
        'name' => user.name,
        'email' => user.email
      )
    end
  end
end
