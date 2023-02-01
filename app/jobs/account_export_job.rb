class AccountExportJob < ApplicationJob
  queue_as :default

  def perform(export)
    return unless export.pending?

    Dir.mktmpdir('export') do |dir|
      Dir.chdir(dir) do
        Dir.mkdir('drafts')
        export.account.posts.draft.find_each do |post|
          File.open(File.join(dir, 'drafts', "#{post.id}.md"), 'w') do |file|
            file.write <<~EOF
              ---
              layout: post
              title: #{post.title}
              author: #{post.user&.name}
              tags: [#{post.tags.pluck(:name).join(', ')}]
              ---

              #{post.content}
            EOF
          end
        end

        Dir.mkdir('posts')
        export.account.posts.published.find_each do |post|
          File.open(File.join(dir, 'posts', "#{post.id}.md"), 'w') do |file|
            file.write <<~EOF
              ---
              layout: post
              title: #{post.title}
              date: #{post.published_at.to_s}
              author: #{post.user&.name}
              tags: [#{post.tags.pluck(:name).join(', ')}]
              ---

              #{post.content}
            EOF
          end
        end

        Dir.mkdir('attachments')
        export.account.posts.find_each do |post|
          post.content.scan(/!\[.*\]\(\/attachments\/(?<key>\w+)\/.*\)/) do |match|
            if attachment = Attachment.find_by(key: match[0])
              Dir.mkdir(File.join('attachments', attachment.key))
              attachment.file.open do |file|
                system 'cp', file.path, File.join(dir, 'attachments', attachment.key, attachment.file.filename.to_s)
              end
            end
          end
        end

        system 'tar', '-czf', 'export.tar.gz', 'posts', 'drafts', 'attachments'

        export.file.attach io: File.open('export.tar.gz'), filename: "#{export.account.name}_export_#{export.created_at.to_fs :number}.tar.gz"
      end
    end

    export.completed!

    if export.account.user?
      AccountMailer.with(account: export.account, user: export.account.owner).export_completed.deliver_later
    else
      export.account.members.where(role: ['owner', 'admin']).each do |user|
        AccountMailer.with(account: export.account, user: user).export_completed.deliver_later
      end
    end
  end
end
