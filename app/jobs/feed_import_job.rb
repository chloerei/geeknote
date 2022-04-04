class FeedImportJob < ApplicationJob
  queue_as :low

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
      if !account.posts.exists?(feed_source_id: entry[:id])
        account.posts.create(
          title: entry[:title],
          content: convert_content(entry[:content], entry[:url], account),
          feed_source_id: entry[:id],
          feed_source_url: entry[:url],
          canonical_url: account.feed_mark_canonical? ? entry[:url]: nil,
          published_at: entry[:published_at]
        )
      end
    rescue ActiveRecord::RecordNotUnique
      next
    end
  end

  def parse_as_atom(account, body)
    xml = Nokogiri::XML(body)

    xml.css('entry').map do |entry|
      {
        id: entry.at('id').content,
        title: entry.at('title').content,
        content: entry.at('content').content,
        url: entry.at('link[type="text/html"]').attribute('href'),
        published_at: DateTime.parse(entry.at('published').content)
      }
    end
  end

  def parse_as_rss(account, body)
    xml = Nokogiri::XML(body)

    xml.css('item').map do |item|
      {
        id: item.at('guid').content,
        title: item.at('title').content,
        content: item.at('description').content,
        url: item.at('link').content,
        published_at: DateTime.parse(item.at('pubDate').content)
      }
    end
  end

  def convert_content(html, url_base, account)
    doc = Nokogiri::HTML.fragment(html)

    doc.css("a").each do |node|
      node['href'] = URI.join(url_base, node['href'])
    rescue URI::InvalidURIError
      next
    end

    doc.css("img").each do |node|
      uri = URI.join(url_base, node['src'])

      if uri.scheme.in? %w(http https)
        node['src'] = uri

        begin
          response = RestClient.head uri.to_s

          if response.headers[:content_length].to_i < 10 * 1024 * 1024
            raw = RestClient::Request.execute method: :get, url: uri.to_s, raw_response: true
            attachment = account.attachments.new
            attachment.file.attach(io: raw.file, filename: File.basename(uri.path))
            attachment.save!
            node['src'] = "/attachments/#{attachment.key}/#{attachment.file.filename.to_s}"
          end
        rescue RestClient::Exception,
               SystemCallError,
               OpenSSL::SSL::SSLError
          next
        end
      end
    rescue URI::InvalidURIError
      next
    end

    ReverseMarkdown.convert(doc.to_s, github_flavored: true)
  end
end
