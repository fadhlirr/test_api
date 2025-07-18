require 'rails_helper'

RSpec.describe UserSerializer do
  describe 'serialization' do
    let(:user) { FactoryBot.create(:user) }
    let!(:job1) { FactoryBot.create(:job, user: user, title: "Job A") }
    let!(:job2) { FactoryBot.create(:job, user: user, title: "Job B") }

    subject { described_class.new(user) }
    let(:serialization) { ActiveModelSerializers::Adapter.create(subject) }
    let(:serialized_data) { JSON.parse(serialization.to_json) }

    it 'includes the correct user attributes' do
      data = serialized_data
      expect(data).to include(
        'id' => user.id,
        'name' => user.name,
        'email' => user.email,
        'phone' => user.phone,
        'created_at' => user.created_at.as_json,
        'updated_at' => user.updated_at.as_json
      )
    end

    it 'includes associated jobs' do
      data = serialized_data
      expect(data['jobs']).to be_an(Array)
      expect(data['jobs'].map { |j| j['id'] }).to contain_exactly(job1.id, job2.id)
    end
  end
end
