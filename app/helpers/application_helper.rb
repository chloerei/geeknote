module ApplicationHelper

  MARKDOWN_ALLOW_TAGS = Set.new(%w(strong em b i p code pre tt samp kbd var sub sup dfn cite big small address hr br div span h1 h2 h3 h4 h5 h6 ul ol li dl dt dd abbr acronym a img blockquote del ins input))
  MARKDOWN_ALLOW_ATTRIBUTES = Set.new(%w(href src width height alt cite datetime title class name xml:lang abbr type disabled))

  def markdown_render(text)
    doc = CommonMarker.render_doc(text, :DEFAULT, [:table, :tasklist, :strikethrough, :autolink, :tagfilter])
    sanitize doc.to_html([:HARDBREAKS]), tags: MARKDOWN_ALLOW_TAGS, attributes: MARKDOWN_ALLOW_ATTRIBUTES
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

  def banner_image_tag(cover)
    if cover.attached?
      if use_aliyun_oss?
        image_tag cover.url(params: { 'x-oss-process' => 'image/resize,m_fill,h_1920,w_1920'})
      else
        image_tag cover.variant(resize_to_limit: [1920, 1920])
      end
    else
      content_tag 'div', '', class: 'banner-image-placeholder'
    end
  end
end
