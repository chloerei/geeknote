class FeedImportJob < ApplicationJob
  queue_as :default

  def perform(account)
    body = Net::HTTP.get(URI(account.feed_url))

    entries = case body
    when /<feed/
      parse_as_atom(account, body)
    when /<rss/
      parse_as_rss(account, body)
    else
      []
    end

    entries.each do |entry|
      account.posts.create!(entry)
    rescue ActiveRecord::RecordNotUnique
      next
    end
  end

  def parse_as_atom(account, body)
    xml = Nokogiri::XML(body)

    xml.css('entry').map do |entry|
      feed_source_url = entry.at('link[type="text/html"]').attribute('href')

      {
        title: entry.at('title').content,
        content: convert_content(entry.at('content').content, feed_source_url),
        feed_source_id: entry.at('id').content,
        feed_source_url: feed_source_url,
        canonical_url: (account.feed_mark_canonical? ? feed_source_url : nil),
        published_at: DateTime.parse(entry.at('updated').content)
      }
    end
  end

  def parse_as_rss(account, body)
    xml = Nokogiri::XML(body)

    xml.css('item').map do |item|
      feed_source_url = item.at('link').content

      {
        title: item.at('title').content,
        content: convert_content(item.at('description').content, feed_source_url),
        feed_source_id: item.at('guid').content,
        feed_source_url: feed_source_url,
        canonical_url: (account.feed_mark_canonical? ? feed_source_url : nil),
        published_at: DateTime.parse(item.at('pubDate').content)
      }
    end
  end

  def convert_content(html, url_base)
    doc = Nokogiri::HTML.fragment(html)

    doc.css("a").each do |node|
      node['href'] = URI.join(url_base, node['href'])
    rescue URI::InvalidURIError
      next
    end

    doc.css("img").each do |node|
      node['src'] = URI.join(url_base, node['src'])
    rescue URI::InvalidURIError
      next
    end

    ReverseMarkdown.convert(doc.to_s, github_flavored: true)
  end
end
