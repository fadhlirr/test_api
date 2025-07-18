FactoryBot.define do
  factory :job do
    title { "Sample Job Title" }
    description { "This is a sample job description." }
    status { "pending" }
    association :user 
  end
end