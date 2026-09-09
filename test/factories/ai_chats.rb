FactoryBot.define do
  factory :ai_chat, class: "AI::Chat" do
    post
    user
    model { "deepseek-v4-flash" }
    provider { "deepseek" }
  end
end
