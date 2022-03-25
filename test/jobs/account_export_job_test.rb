require "test_helper"

class AccountExportDataJobTest < ActiveJob::TestCase
  test "should export account data" do
    account = create(:user_account)
    account.owner.update name: 'User Name'

    post_1 = account.posts.create(
      title: 'post title 1',
      content:  'post content 1',
      author_users: [account.owner],
      status: 'draft'
    )

    post_2 = account.posts.create(
      title: 'post title 2',
      content:  'post content 2',
      author_users: [account.owner],
      status: 'published',
      published_at: DateTime.new(2022, 1, 1),
      tag_list: ['Ruby', 'JavaScript']
    )

    attachment = account.attachments.create user: account.owner
    attachment.file.attach(io: File.open('test/fixtures/files/avatar.png'), filename: 'avatar.png')

    export = account.exports.create
    AccountExportJob.perform_now(export)
    assert export.file.attached?

    Dir.mktmpdir do |dir|
      export.file.open do |file|
        system 'tar', '-xzf', file.path, '-C', dir

        assert File.exist?(File.join(dir, 'drafts', "#{post_1.id}.md"))
        assert_equal <<~EOF, File.read(File.join(dir, 'drafts', "#{post_1.id}.md"))
          ---
          layout: post
          title: post title 1
          authors: [User Name]
          tags: []
          ---

          post content 1
        EOF

        assert File.exist?(File.join(dir, 'posts', "#{post_2.id}.md"))
        assert_equal <<~EOF, File.read(File.join(dir, 'posts', "#{post_2.id}.md"))
          ---
          layout: post
          title: post title 2
          date: 2022-01-01 00:00:00 UTC
          authors: [User Name]
          tags: [Ruby, JavaScript]
          ---

          post content 2
        EOF

        assert File.exist?(File.join(dir, 'attachments', attachment.key, attachment.file.filename.to_s))
      end
    end
  end
end
