class FeedImportJob < ApplicationJob
  queue_as :default

  def perform(account)
    body = Net::HTTP.get(URI(account.feed_url))

    case body
    when /<feed/
      parse_as_atom(account, body)
    when /<rss/
      parse_as_rss(account, body)
    end
  end

  def parse_as_atom(account, body)
    xml = Nokogiri::XML(body)

    xml.css('entry').each do |entry|
      feed_source_url = entry.at('link[type="text/html"]').attribute('href')

      account.posts.create!(
        title: entry.at('title').content,
        content: entry.at('content').content,
        feed_source_id: entry.at('id').content,
        feed_source_url: feed_source_url,
        canonical_url: (account.feed_mark_canonical? ? feed_source_url : nil),
        published_at: DateTime.parse(entry.at('updated').content)
      )
    rescue ActiveRecord::RecordNotUnique
      next
    end
  end

  def parse_as_rss(account, body)
    xml = Nokogiri::XML(body)

    xml.css('item').each do |item|
      feed_source_url = item.at('link').content

      account.posts.create!(
        title: item.at('title').content,
        content: item.at('description').content,
        feed_source_id: item.at('guid').content,
        feed_source_url: feed_source_url,
        canonical_url: (account.feed_mark_canonical? ? feed_source_url : nil),
        published_at: DateTime.parse(item.at('pubDate').content)
      )
    rescue ActiveRecord::RecordNotUnique
      next
    end
  end
end
