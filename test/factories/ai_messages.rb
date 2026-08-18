FactoryBot.define do
  factory :ai_message, class: "AI::Message" do
    ai_chat
    role { "user" }
    content { "Hello" }
  end
end
