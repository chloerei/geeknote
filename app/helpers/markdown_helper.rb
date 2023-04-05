module MarkdownHelper
  MARKDOWN_ALLOW_TAGS = Set.new(%w(strong em b i p code pre tt samp kbd var sub sup dfn cite big small address hr br div span h1 h2 h3 h4 h5 h6 ul ol li dl dt dd abbr acronym a img blockquote del ins input table thead tbody tr th td))
  MARKDOWN_ALLOW_ATTRIBUTES = Set.new(%w(id href src width height alt cite datetime title class name xml:lang abbr type disabled checked))

  def markdown_render(text)
    html = CommonMarker.render_html(text, :DEFAULT, [:table, :tasklist, :strikethrough, :autolink, :tagfilter])
    doc = Nokogiri::HTML.fragment(html)

    # code highlight
    doc.css("pre code").each do |node|
      lang = node["class"].to_s.gsub('language-', '')
      lexer = Rouge::Lexer.find_fancy(lang) || Rouge::Lexer.find_fancy('text')
      formatter = Rouge::Formatters::HTML.new
      node.inner_html = formatter.format(lexer.lex(node.content))
      node.parent.add_class("highlight")
    end

    # Add header anchor
    doc.css("h1, h2, h3, h4, h5, h6").each do |node|
      anchor = Nokogiri::XML::Node.new "a", doc
      anchor["id"] = CGI.escape(node.text)
      anchor["href"] = "##{anchor['id']}"
      anchor["class"] = "anchor"
      node.prepend_child anchor
    end

    sanitize doc.to_html, tags: MARKDOWN_ALLOW_TAGS, attributes: MARKDOWN_ALLOW_ATTRIBUTES
  end

end
