FactoryBot.define do
  factory :membership do
    organization
    user
    role { 'member' }
  end
end
