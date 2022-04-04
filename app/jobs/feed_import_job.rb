class FeedImportJob < ApplicationJob
  queue_as :low

  def perform(account)
    body = RestClient.get(account.feed_url).body

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
        post = account.posts.create(
          title: entry[:title],
          content: convert_content(entry[:content], entry[:url], account),
          feed_source_id: entry[:id],
          canonical_url: account.feed_mark_canonical? ? entry[:url]: nil,
          published_at: entry[:published_at]
        )

        if account.user?
          post.author_users << account.owner
        end
      end
    end

    account.update feed_fetched_at: Time.now
  rescue RestClient::Exception,
         SystemCallError,
         OpenSSL::SSL::SSLError
    # ignore
  end

  def parse_as_atom(account, body)
    xml = Nokogiri::XML(body)

    xml.css('entry').take(100).map do |entry|
      {
        id: entry.at_css('id')&.content,
        title: entry.at_css('title')&.content,
        content: entry.at_css('content')&.content,
        url: entry.at_css('link[type="text/html"]')&.attribute('href'),
        published_at: (DateTime.parse(entry.at_css('published')&.content) rescue nil)
      }
    end
  end

  def parse_as_rss(account, body)
    xml = Nokogiri::XML(body)

    xml.css('item').take(100).map do |item|
      {
        id: item.at_css('guid')&.content,
        title: item.at_css('title')&.content,
        content: item.at_css('description')&.content,
        url: item.at_css('link')&.content,
        published_at: (DateTime.parse(item.at_css('pubDate')&.content) rescue nil)
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
