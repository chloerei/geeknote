FactoryBot.define do
  factory :bookmark do
    user
    post factory: :published_post
  end
end
