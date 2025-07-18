require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:jobs).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:phone) }
    it { should validate_uniqueness_of(:email) }
    
    context 'email format' do
      it 'should allow valid email formats' do
        user = User.new(
          name: 'Test User',
          email: 'test@example.com',
          phone: '1234567890'
        )
        expect(user).to be_valid
      end

      it 'should not allow invalid email formats' do
        user = User.new(
          name: 'Test User',
          email: 'invalid-email',
          phone: '1234567890'
        )
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include('is invalid')
      end
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      user = FactoryBot.build(:user)
      expect(user).to be_valid
    end
  end
end
