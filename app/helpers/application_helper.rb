module ApplicationHelper

  MARKDOWN_ALLOW_TAGS = Set.new(%w(strong em b i p code pre tt samp kbd var sub sup dfn cite big small address hr br div span h1 h2 h3 h4 h5 h6 ul ol li dl dt dd abbr acronym a img blockquote del ins input table thead tbody tr th td))
  MARKDOWN_ALLOW_ATTRIBUTES = Set.new(%w(id href src width height alt cite datetime title class name xml:lang abbr type disabled checked))

  def markdown_render(text)
    html = Commonmarker.to_html(text)
    doc = Nokogiri::HTML.fragment(html)

    # code highlight
    doc.css("pre code").each do |node|
      lang = node.parent.attr("lang")
      lexer = Rouge::Lexer.find_fancy(lang) || Rouge::Lexer.find_fancy('text')
      formatter = Rouge::Formatters::HTML.new
      node.inner_html = formatter.format(lexer.lex(node.content))
      node.parent.add_class("highlight")
    end

    # fix turbo anchor navigator
    doc.css(".anchor").each do |node|
      node["id"] = CGI.escape node["id"]
    end

    sanitize doc.to_html, tags: MARKDOWN_ALLOW_TAGS, attributes: MARKDOWN_ALLOW_ATTRIBUTES
  end

  def use_aliyun_oss?
    ENV['STORAGE_SERVICE'] == 'aliyun'
  end

  def avatar_url(avatar)
    if avatar.attached?
      if use_aliyun_oss?
        avatar.url(params: { 'x-oss-process' => 'image/resize,m_fill,w_160,h_160'})
      else
        url_for avatar.variant(resize_to_fill: [160, 160])
      end
    else
      asset_path('avatar.png')
    end
  end

  def avatar_image_tag(avatar)
    if avatar.attached?
      if use_aliyun_oss?
        image_tag avatar.url(params: { 'x-oss-process' => 'image/resize,m_fill,w_160,h_160'})
      else
        image_tag avatar.variant(resize_to_fill: [160, 160])
      end
    else
      image_tag asset_url('avatar.png')
    end
  end

  def banner_image_tag(banner_image)
    if banner_image.attached?
      if use_aliyun_oss?
        image_tag banner_image.url(params: { 'x-oss-process' => 'image/resize,m_lfit,w_1920,h_1920'})
      else
        image_tag banner_image.variant(resize_to_limit: [1920, 1920])
      end
    else
      content_tag 'div', '', class: 'banner-image-placeholder'
    end
  end

  def featured_image_thumb_tag(featured_image)
    if featured_image.attached?
      if use_aliyun_oss?
        image_tag featured_image.url(params: { 'x-oss-process' => 'image/resize,m_fill,w_256,h_256'})
      else
        image_tag featured_image.variant(resize_to_fill: [256, 256])
      end
    end
  end

  def featured_image_square_tag(featured_image)
    if featured_image && featured_image.attached?
      if use_aliyun_oss?
        image_tag featured_image.url(params: { 'x-oss-process' => 'image/resize,m_fill,w_400,h_400'})
      else
        image_tag featured_image.variant(resize_to_fill: [400, 400])
      end
    else
      content_tag 'div', class: 'featured-image-placeholder' do
        content_tag 'span', 'article', class: 'material-icons'
      end
    end
  end

  def featured_image_tag(featured_image)
    if featured_image.attached?
      options = featured_image.metadata.slice(:width, :height)

      if use_aliyun_oss?
        image_tag featured_image.url(params: { 'x-oss-process' => 'image/resize,m_lfit,w_1920,h_1920'}), options
      else
        image_tag featured_image.variant(resize_to_limit: [1920, 1920]), options
      end
    end
  end

  def featured_image_url(featured_image)
    if featured_image.attached?
      if use_aliyun_oss?
        featured_image.url(params: { 'x-oss-process' => 'image/resize,m_lfit,w_1920,h_1920'})
      else
        url_for featured_image.variant(resize_to_limit: [1920, 1920])
      end
    end
  end

  def post_summary(post, length: 100)
    if post.excerpt.present?
      truncate post.excerpt, length: length
    else
      truncate strip_tags(markdown_render(post.content)), length: length, escape: false
    end
  end

  def post_toc(post)
    doc = Nokogiri::HTML.fragment(markdown_render(post.content || ""))
    toc = doc.css("h2, h3").map do |heading|
      anchor = heading.css(".anchor")
      {
        title: heading.text.strip,
        href: anchor.attr("href"),
        id: anchor.attr("id"),
        level: heading.name[1].to_i
      }
    end
    toc
  end

  def comment_summary(comment)
    truncate strip_tags(markdown_render(comment.content)), length: 100, escape: false
  end

  def format_time(time)
    if time
      local_time time, format: :long
    end
  end

  def diff_html(from, to)
    sanitize Diffy::Diff.new(from.to_s, to.to_s, allow_empty_diff: false).to_s(:html)
  end

  def link_to_canonical_url(url)
    uri = URI.parse(url) rescue nil
    if uri.kind_of?(URI::HTTP) || uri.kind_of?(URI::HTTPS)
      link_to uri.host, uri.to_s
    end
  end

  def recaptcha_tag
    if defined?(Recaptcha)
      content_tag 'div', '', class: 'g-recaptcha', data: { sitekey: ENV['RECAPTCHA_SITE_KEY'], controller: 'recaptcha' }
    end
  end
end
