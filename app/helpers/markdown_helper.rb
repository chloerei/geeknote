module MarkdownHelper
  MARKDOWN_ALLOW_TAGS = %w[strong em b i p code pre tt samp kbd var sub sup dfn cite big small address hr br div span h1 h2 h3 h4 h5 h6 ul ol li dl dt dd abbr acronym a img blockquote del ins input table thead tbody tr th td video]
  MARKDOWN_ALLOW_ATTRIBUTES = %w[id href src width height alt cite datetime title class name xml:lang abbr type disabled checked controls allowfullscreen start]

  class MarkdownScruber < Rails::Html::PermitScrubber
    def initialize
      super
      self.tags = MARKDOWN_ALLOW_TAGS
      self.attributes = MARKDOWN_ALLOW_ATTRIBUTES
    end

    protected

    def allowed_node?(node)
      allowed = super
      return true if allowed

      case node.name
      when "iframe"
        return allow_iframe?(node)
      end

      false
    end

    def allow_iframe?(node)
      src = node["src"]
      return false unless src

      case src
      when %r{^https://www.youtube.com/embed/}
        true
      when %r{^https://player.bilibili.com/player.html}
        true
      else
        false
      end
    end
  end

  def markdown_render(text)
    html = CommonMarker.render_html(text, :DEFAULT, [ :table, :tasklist, :strikethrough, :autolink, :tagfilter ])
    doc = Nokogiri::HTML5.fragment(html)

    # code highlight
    doc.css("pre code").each do |node|
      lang = node["class"].to_s.gsub("language-", "")
      lexer = Rouge::Lexer.find_fancy(lang) || Rouge::Lexer.find_fancy("text")
      formatter = Rouge::Formatters::HTML.new
      node.inner_html = formatter.format(lexer.lex(node.content))
      node.parent.add_class("highlight")
    end

    # Add header anchor
    doc.css("h1, h2, h3, h4, h5, h6").each do |node|
      node["id"] = CGI.escape(node.text)
    end

    # search p a as only child
    doc.css("p a:only-child").each do |node|
      # ensure not other text in parent node
      if node.parent.text != node.text
        next
      end

      # match attachment url
      if match = node["href"].match(%r{^/attachments/(?<key>\w+)})
        if attachment = Attachment.find_by(key: match[:key])
          if attachment.file.video?
            node.replace %(<video src="#{match[0]}" controls="controls"></video>)
          end
        end
        next
      end

      # match youtube url
      if match = node["href"].match(%r{^https://www.youtube.com/watch\?v=(?<id>\w+)})
        node.replace %(<iframe src="https://www.youtube.com/embed/#{match[:id]}" allowfullscreen></iframe>)
        next
      end

      # match bilibili url
      if match = node["href"].match(%r{^https://www.bilibili.com/video/(?<id>\w+)})
        node.replace %(<iframe src="https://player.bilibili.com/player.html?bvid=#{match[:id]}" allowfullscreen></iframe>)
        next
      end
    end

    # wrap table with div
    tables = doc.css("table")
    tables.wrap("<div class='table-wrapper'></div>")

    sanitize doc.to_html, scrubber: MarkdownScruber.new
  end

  def markdown_summary(text)
    html = CommonMarker.render_html(text, :DEFAULT, [ :table, :tasklist, :strikethrough, :autolink, :tagfilter ])
    doc = Nokogiri::HTML.fragment(sanitize html)

    first_paragraph = doc.css("p").first

    text = first_paragraph&.text || ""
    truncate(text, length: 140)
  end

  def markdown_toc(text)
    html = CommonMarker.render_html(text, :DEFAULT, [ :table, :tasklist, :strikethrough, :autolink, :tagfilter ])
    doc = Nokogiri::HTML5.fragment(sanitize html)

    toc = []

    doc.css("h2, h3").each do |node|
      if node.name == "h2"
        toc << { level: 2, text: node.text, id: CGI.escape(node.text) }
      elsif node.name == "h3"
        if toc.last && toc.last[:level] == 2
          toc.last[:children] ||= []
          toc.last[:children] << { level: 3, text: node.text, id: CGI.escape(node.text) }
        end
      end
    end

    toc
  end
end
