require "test_helper"

class AccountExportDataJobTest < ActiveJob::TestCase
  test "should export account data" do
    account = create(:user_account)
    account.owner.update name: "User Name"

    post_1 = account.posts.create(
      title: "post title 1",
      content:  "post content 1",
      user: account.owner,
      status: "draft"
    )

    post_2 = account.posts.create(
      title: "post title 2",
      content:  "post content 2",
      user: account.owner,
      status: "published",
      published_at: DateTime.new(2022, 1, 1),
      tag_list: "Ruby,JavaScript"
    )

    attachment = Attachment.new user: account.owner
    attachment.file.attach(io: File.open("test/fixtures/files/avatar.png"), filename: "avatar.png")
    attachment.save

    post_3 = account.posts.create(
      title: "Attachment",
      content:  "![](/attachments/#{attachment.key})",
      user: account.owner,
      status: "published",
      published_at: DateTime.new(2022, 1, 1)
    )

    export = account.create_export
    AccountExportJob.perform_now(export)
    assert export.file.attached?

    Dir.mktmpdir do |dir|
      export.file.open do |file|
        system "tar", "-xzf", file.path, "-C", dir

        assert File.exist?(File.join(dir, "posts", "#{post_1.id}.md"))
        assert_equal <<~EOF, File.read(File.join(dir, "posts", "#{post_1.id}.md"))
          ---
          layout: post
          title: post title 1
          author: User Name
          tags: []
          published: false
          ---

          post content 1
        EOF

        assert File.exist?(File.join(dir, "posts", "#{post_2.id}.md"))
        assert_equal <<~EOF, File.read(File.join(dir, "posts", "#{post_2.id}.md"))
          ---
          layout: post
          title: post title 2
          author: User Name
          tags: [Ruby, JavaScript]
          date: 2022-01-01 08:00:00 +0800
          ---

          post content 2
        EOF

        assert File.exist?(File.join(dir, "posts", "#{post_3.id}.md"))
        assert_equal <<~EOF, File.read(File.join(dir, "posts", "#{post_3.id}.md"))
          ---
          layout: post
          title: Attachment
          author: User Name
          tags: []
          date: 2022-01-01 08:00:00 +0800
          ---

          ![](http://www.example.com/attachments/#{attachment.key})
        EOF
      end
    end
  end
end
