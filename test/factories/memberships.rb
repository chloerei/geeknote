FactoryBot.define do
  factory :membership do
    organization
    user
    status { 'active' }
    role { 'member' }
  end
end
