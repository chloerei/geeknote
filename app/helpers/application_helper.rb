module ApplicationHelper

  MARKDOWN_ALLOW_TAGS = Set.new(%w(strong em b i p code pre tt samp kbd var sub sup dfn cite big small address hr br div span h1 h2 h3 h4 h5 h6 ul ol li dl dt dd abbr acronym a img blockquote del ins input))
  MARKDOWN_ALLOW_ATTRIBUTES = Set.new(%w(href src width height alt cite datetime title class name xml:lang abbr type disabled))

  def markdown_render(text)
    doc = CommonMarker.render_doc(text, :DEFAULT, [:table, :tasklist, :strikethrough, :autolink, :tagfilter])
    sanitize doc.to_html([:HARDBREAKS]), tags: MARKDOWN_ALLOW_TAGS, attributes: MARKDOWN_ALLOW_ATTRIBUTES
  end

  def avatar_image_tag(avatar)
    if avatar.attached?
      image_tag avatar.variant(resize_to_fill: [160, 160])
    else
      image_tag asset_pack_path('media/images/avatar.png')
    end
  end

  def cover_image_tag(cover)
    if cover.attached?
      image_tag cover.variant(resize_to_limit: [1920, 1920])
    else
      content_tag 'div', '', class: 'cover-image-placeholder'
    end
  end
end
