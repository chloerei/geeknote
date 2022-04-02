require "test_helper"

class FeedImportJobTest < ActiveJob::TestCase
  test "should import atom feed" do
    account = create(:user_account, feed_url: 'https://example.com/feed.xml', feed_mark_canonical: true)

    stub_request(:get, 'https://example.com/feed.xml').to_return(body: <<~EOF)
      <?xml version="1.0" encoding="utf-8"?>
      <feed xmlns="http://www.w3.org/2005/Atom">
        <title>Site Title</title>
        <subtitle>Subtitle</subtitle>
        <link href="https://example.com/feed.xml" rel="self" />
        <link href="http://example.com/" />
        <id>urn:uuid:417c8563-3ddd-41a6-a58b-cc0f1d47e643</id>
        <updated>2022-01-01T00:00:00+00:00</updated>
        <author>
          <name>Author</name>
          <email>author@example.com</email>
        </author>

        <entry>
          <title>Post Title</title>
          <link type="text/html" href="https://example.com/2022/01/01/post-title" />
          <id>urn:uuid:5d563d8d-65f4-44c4-b7d9-f2af8fc012b5</id>
          <published>2022-01-01T00:00:00+00:00</published>
          <summary>Post summary.</summary>
          <content>Post content.</content>
        </entry>

      </feed>
    EOF

    assert_difference "account.posts.count" do
      FeedImportJob.perform_now(account)
    end
    post = account.posts.last
    assert_equal 'Post Title', post.title
    assert_equal "Post content.\n\n", post.content
    assert_equal 'urn:uuid:5d563d8d-65f4-44c4-b7d9-f2af8fc012b5', post.feed_source_id
    assert_equal 'https://example.com/2022/01/01/post-title', post.feed_source_url
    assert_equal 'https://example.com/2022/01/01/post-title', post.canonical_url
    assert_equal DateTime.new(2022, 1, 1), post.published_at

    # Will not create duplicate post
    assert_no_difference "account.posts.count" do
      FeedImportJob.perform_now(account)
    end
  end

  test "should import rss feed" do
    account = create(:user_account, feed_url: 'https://example.com/feed.xml', feed_mark_canonical: true)

    stub_request(:get, 'https://example.com/feed.xml').to_return(body: <<~EOF)
      <?xml version="1.0" encoding="UTF-8" ?>
      <rss version="2.0">
        <channel>
          <title>Site Title</title>
          <description>Site description</description>
          <link>https://example.com/</link>
          <pubDate>Sat, 1 Jan 2022 00:00:00 +0000</pubDate>

          <item>
            <title>Post Title</title>
            <description>Post content.</description>
            <link>https://example.com/2022/01/01/post-title</link>
            <guid isPermaLink="false">5d563d8d-65f4-44c4-b7d9-f2af8fc012b5</guid>
            <pubDate>Sat, 1 Jan 2022 00:00:00 +0000</pubDate>
          </item>

        </channel>
      </rss>
    EOF

    assert_difference "account.posts.count" do
      FeedImportJob.perform_now(account)
    end
    post = account.posts.last
    assert_equal 'Post Title', post.title
    assert_equal "Post content.\n\n", post.content
    assert_equal '5d563d8d-65f4-44c4-b7d9-f2af8fc012b5', post.feed_source_id
    assert_equal 'https://example.com/2022/01/01/post-title', post.feed_source_url
    assert_equal 'https://example.com/2022/01/01/post-title', post.canonical_url
    assert_equal DateTime.new(2022, 1, 1), post.published_at

    # Will not create duplicate post
    assert_no_difference "account.posts.count" do
      FeedImportJob.perform_now(account)
    end
  end

  test "should covert html content to markdown" do
    result = FeedImportJob.new.convert_content(<<~EOF, "https://example.com/path/to/post")
      <h2>Headline</h2>

      <p>paragraph <b>bold</b>.</p>
    EOF

    assert_equal <<~EOF, result
      ## Headline

      paragraph **bold**.

    EOF
  end

  test "should convert relative path to absolute url" do
    result = FeedImportJob.new.convert_content(<<~EOF, "https://example.com/path/to/post")
      <p><a href="other">inner link</a></p>

      <p><img src="image.png"></p>
    EOF

    assert_equal <<~EOF, result
     [inner link](https://example.com/path/to/other)

     ![](https://example.com/path/to/image.png)

    EOF
  end

  test "should convert absolute path to absolute url" do
    result = FeedImportJob.new.convert_content(<<~EOF, "https://example.com/path/to/post")
      <p><a href="/path/to/other">inner link</a></p>

      <p><img src="/path/to/image.png"></p>
    EOF

    assert_equal <<~EOF, result
     [inner link](https://example.com/path/to/other)

     ![](https://example.com/path/to/image.png)

    EOF
  end

  test "should convert content ignore invalid url" do
    result = FeedImportJob.new.convert_content(<<~EOF, "https://example.com/path/to/post")
      <p><a href="bad url">inner link</a></p>

      <p><img src="bad url"></p>
    EOF

    assert_equal <<~EOF, result
     [inner link](bad%20url)

     ![](bad%20url)

    EOF
  end
end
