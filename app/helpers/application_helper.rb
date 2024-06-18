module ApplicationHelper
  include Pagy::Frontend

  MATERIAL_ICONS = {}
  def material_icon(name)
    MATERIAL_ICONS[name] ||= File.read(Rails.root.join("vendor/icons/@material-symbols/svg-400/rounded/#{name}.svg")).html_safe
  end

  def avatar_url(user)
    if user.avatar.attached?
      polymorphic_url user.avatar.variant(:thumb)
    else
      asset_url("avatar.png")
    end
  end

  def avatar_image_tag(avatar)
  end

  def banner_image_tag(banner_image)
    if banner_image.attached?
      image_tag banner_image.variant(:large)
    else
      content_tag "div", "", class: "banner-image-placeholder"
    end
  end

  def featured_image_tag(featured_image)
    if featured_image.attached?
      options = featured_image.metadata.slice(:width, :height)
      image_tag featured_image.variant(:large), options
    end
  end

  def featured_image_url(featured_image)
    if featured_image.attached?
      polymorphic_url featured_image.variant(:large)
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
        href: anchor.attr("href").to_s,
        id: anchor.attr("id").to_s,
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

  def link_to_canonical_url(url)
    uri = URI.parse(url) rescue nil
    if uri.kind_of?(URI::HTTP) || uri.kind_of?(URI::HTTPS)
      link_to uri.host, uri.to_s
    end
  end

  def recaptcha_tag
    if defined?(Recaptcha)
      content_tag "div", "", class: "g-recaptcha", data: { sitekey: ENV["RECAPTCHA_SITE_KEY"], controller: "recaptcha" }
    end
  end
end
