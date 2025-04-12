require "test_helper"

class TagsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    tag = Tag.create(name: "Foobar")
    get tag_url(tag.name)
    assert_response :success
  end
end
