require "test_helper"

class MarkdownHelperTest < ActionView::TestCase
  test "code render" do
    text = "```ruby\nputs 'hello'\n```"
    assert_equal <<~EOF, markdown_render(text)
<pre class="highlight"><code class="language-ruby"><span class="nb">puts</span> <span class="s1">'hello'</span>
</code></pre>
    EOF
  end
end
