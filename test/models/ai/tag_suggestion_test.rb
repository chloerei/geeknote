require "test_helper"

class AI::TagSuggestionTest < ActiveSupport::TestCase
  test "parses a comma separated reply into tags" do
    assert_equal %w[rails performance benchmarking], suggest(reply: "rails, performance, benchmarking")
  end

  test "returns no tags and does not call the model when the content is blank" do
    tags = AI::TagSuggestion.new(title: "Title", content: "  ").call

    assert_equal [], tags
    assert_not_requested :post, AI_COMPLETION_URL
  end

  test "offers the tags used by more than one post, most used first" do
    create(:tag, name: "rails", taggings_count: 5)
    create(:tag, name: "ruby", taggings_count: 3)
    create(:tag, name: "usedonce", taggings_count: 1)
    create(:tag, name: "unused", taggings_count: 0)

    # Tags are not covered by fixtures, so leftovers from a manual run could be
    # in the list: only what this test created is asserted.
    tags = AI::TagSuggestion.popular_tags

    assert_includes tags, "rails"
    assert_includes tags, "ruby"
    assert_operator tags.index("rails"), :<, tags.index("ruby")
    assert_not_includes tags, "usedonce"
    assert_not_includes tags, "unused"
  end

  test "is unavailable without a configured default model" do
    with_default_model(nil) do
      assert_not AI::TagSuggestion.available?
    end

    assert AI::TagSuggestion.available?
  end

  private

  def suggest(reply:)
    stub_ai_completion(reply)
    AI::TagSuggestion.new(title: "Title", content: "Content").call
  end
end
