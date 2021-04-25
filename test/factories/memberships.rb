FactoryBot.define do
  factory :membership do
    organization
    user
    status { 'active' }
    role { 'member' }

    factory :invitation do
      user { nil }
      status { 'pending' }
      inviter factory: :user
      sequence(:invitation_email) { |n| "username#{n}@example.com" }
      invited_at { Time.now }
    end
  end
end
