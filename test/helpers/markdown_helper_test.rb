require "test_helper"

class MarkdownHelperTest < ActionView::TestCase
  test "code render" do
    text = <<~EOF
     ```ruby
     puts "hello"
     ```
    EOF

    html = <<~EOF
      <pre class="highlight"><code class="language-ruby"><span class="nb">puts</span> <span class="s2">"hello"</span>
      </code></pre>
    EOF

    assert_equal html, markdown_render(text)
  end

  test "header anchor" do
    text = <<~EOF
      # Header 1

      ## Header 2

      ## 中文
    EOF

    html = <<~EOF
      <h1>
      <a id="Header+1" href="#Header+1" class="anchor"></a>Header 1</h1>
      <h2>
      <a id="Header+2" href="#Header+2" class="anchor"></a>Header 2</h2>
      <h2>
      <a id="%E4%B8%AD%E6%96%87" href="#%E4%B8%AD%E6%96%87" class="anchor"></a>中文</h2>
    EOF

    assert_equal html, markdown_render(text)
  end
end
