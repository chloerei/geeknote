class AccountBackupJob < ApplicationJob
  queue_as :default

  def perform(backup)
    return unless backup.pending?

    Dir.mktmpdir('backup') do |dir|
      Dir.chdir(dir) do
        Dir.mkdir('drafts')
        backup.account.posts.draft.find_each do |post|
          File.open(File.join(dir, 'drafts', "#{post.id}.md"), 'w') do |file|
            file.write <<~EOF
              ---
              layout: post
              title: #{post.title}
              author: [#{post.author_users.pluck(:name).join(', ')}]
              tags: [#{post.tags.pluck(:name).join(', ')}]
              ---

              #{post.content}
            EOF
          end
        end

        Dir.mkdir('posts')
        backup.account.posts.published.find_each do |post|
          File.open(File.join(dir, 'posts', "#{post.id}.md"), 'w') do |file|
            file.write <<~EOF
              ---
              layout: post
              title: #{post.title}
              date: #{post.published_at.to_s}
              author: [#{post.author_users.pluck(:name).join(', ')}]
              tags: [#{post.tags.pluck(:name).join(', ')}]
              ---

              #{post.content}
            EOF
          end
        end

        Dir.mkdir('attachments')
        backup.account.attachments.find_each do |attachment|
          Dir.mkdir(File.join('attachments', attachment.key))
          attachment.file.open do |file|
            system 'cp', file.path, File.join(dir, 'attachments', attachment.key, attachment.file.filename.to_s)
          end
        end

        system 'tar', '-czf', 'backup.tar.gz', 'posts', 'drafts', 'attachments'

        backup.file.attach io: File.open('backup.tar.gz'), filename: 'backup.tar.gz'
      end
    end

    backup.completed!
  end

end
