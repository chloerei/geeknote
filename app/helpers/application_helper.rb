module ApplicationHelper
  def markdown_render(text)
    doc = CommonMarker.render_doc(text, :DEFAULT, [:table, :tasklist, :strikethrough, :autolink, :tagfilter])
    sanitize doc.to_html([:HARDBREAKS])
  end
end
