module ApplicationHelper

  MARKDOWN_ALLOW_TAGS = Set.new(%w(strong em b i p code pre tt samp kbd var sub sup dfn cite big small address hr br div span h1 h2 h3 h4 h5 h6 ul ol li dl dt dd abbr acronym a img blockquote del ins input table thead tbody tr th td))
  MARKDOWN_ALLOW_ATTRIBUTES = Set.new(%w(href src width height alt cite datetime title class name xml:lang abbr type disabled checked))

  def markdown_render(text)
    doc = CommonMarker.render_doc(text, :DEFAULT, [:table, :tasklist, :strikethrough, :autolink, :tagfilter])

    # highlight commonmarker code block with rouge
    doc.walk do |node|
      if node.type == :code_block
        next if node.fence_info == ''

        lang = node.fence_info
        lexer = Rouge::Lexer.find_fancy(lang) || Rouge::Lexer.find_fancy('text')
        formatter = Rouge::Formatters::HTML.new
        code = formatter.format(lexer.lex(node.string_content))
        new_node = CommonMarker::Node.new(:html)
        new_node.string_content = %Q(<pre><code class="language-#{lang} highlight">#{code}</code></pre>)

        node.insert_before(new_node)
        node.delete
      end
    end

    sanitize doc.to_html([:HARDBREAKS, :UNSAFE]), tags: MARKDOWN_ALLOW_TAGS, attributes: MARKDOWN_ALLOW_ATTRIBUTES
  end

  def use_aliyun_oss?
    ENV['STORAGE_SERVICE'] == 'aliyun'
  end

  def avatar_image_tag(avatar)
    if avatar.attached?
      if use_aliyun_oss?
        image_tag avatar.url(params: { 'x-oss-process' => 'image/resize,m_fill,h_160,w_160'})
      else
        image_tag avatar.variant(resize_to_fill: [160, 160])
      end
    else
      image_tag asset_pack_path('media/images/avatar.png')
    end
  end

  def large_avatar_image_tag(avatar)
    if avatar.attached?
      if use_aliyun_oss?
        image_tag avatar.url(params: { 'x-oss-process' => 'image/resize,m_fill,h_320,w_320'})
      else
        image_tag avatar.variant(resize_to_fill: [320, 320])
      end
    else
      image_tag asset_pack_path('media/images/avatar.png')
    end
  end

  def banner_image_tag(banner_image)
    if banner_image.attached?
      if use_aliyun_oss?
        image_tag banner_image.url(params: { 'x-oss-process' => 'image/resize,m_lfit,h_1920,w_1920'})
      else
        image_tag banner_image.variant(resize_to_limit: [1920, 1920])
      end
    else
      content_tag 'div', '', class: 'banner-image-placeholder'
    end
  end

  def post_summary(post)
    if post.excerpt.present?
      truncate post.excerpt, length: 100
    else
      truncate strip_tags(markdown_render(post.content)), length: 100
    end
  end

  def comment_summary(comment)
    truncate strip_tags(markdown_render(comment.content)), length: 100
  end
end
