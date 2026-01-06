require "test_helper"

class MarkdownHelperTest < ActionView::TestCase
  test "code render" do
    text = <<~EOF
     ```ruby
     puts "hello"
     ```
    EOF

    html = <<~EOF
      <pre lang="ruby" class="highlight"><code><span class="nb">puts</span> <span class="s2">"hello"</span>
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
      <h1 id="Header+1">Header 1</h1>
      <h2 id="Header+2">Header 2</h2>
      <h2 id="%E4%B8%AD%E6%96%87">中文</h2>
    EOF

    assert_equal html, markdown_render(text)
  end

  test "should render youtube link" do
    text = <<~EOF
      https://www.youtube.com/watch?v=abc
    EOF

    html = <<~EOF
      <p><iframe src="https://www.youtube.com/embed/abc" allowfullscreen=""></iframe></p>
    EOF

    assert_equal html, markdown_render(text)
  end

  test "should render bilibili link" do
    text = <<~EOF
      https://www.bilibili.com/video/abc
    EOF

    html = <<~EOF
      <p><iframe src="https://player.bilibili.com/player.html?bvid=abc" allowfullscreen=""></iframe></p>
    EOF

    assert_equal html, markdown_render(text)
  end

  test "should generate toc" do
    text = <<~EOF
      ## Header 2

      ### Header 3

      #### Header 4

      ## Header 5

      #### Header 6

      ### Header 7

      ### Header 8
    EOF

    toc = markdown_toc(text)

    assert_equal [
      {
        level: 2, text: "Header 2", id: "Header+2", children: [
          { level: 3, text: "Header 3", id: "Header+3" }
        ]
      },
      {
        level: 2, text: "Header 5", id: "Header+5", children: [
          { level: 3, text: "Header 7", id: "Header+7" },
          { level: 3, text: "Header 8", id: "Header+8" }
        ]
      }
    ], toc
  end
end
