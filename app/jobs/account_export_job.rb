class AccountExportJob < ApplicationJob
  queue_as :default

  def perform(export)
    return unless export.pending?

    Dir.mktmpdir("export") do |dir|
      Dir.chdir(dir) do
        Dir.mkdir("posts")
        export.account.posts.where(status: [ :draft, :published ]).find_each do |post|
          content = process_attachment_url(post.content)

          File.open(File.join(dir, "posts", "#{post.id}.md"), "w") do |file|
            file.write <<~EOF
              ---
              layout: post
              title: #{post.title}
              author: #{post.user.name}
              tags: [#{post.tags.pluck(:name).join(", ")}]
              #{post.published? ? "date: #{post.published_at}" : "published: false"}
              ---

              #{content}
            EOF
          end
        end

        system "tar", "-czf", "export.tar.gz", "posts"

        export.file.attach io: File.open("export.tar.gz"), filename: "#{export.account.name}_export_#{export.created_at.to_fs :number}.tar.gz"
      end
    end

    export.completed!

    if export.account.user?
      AccountMailer.with(account: export.account, user: export.account.owner).export_completed.deliver_later
    else
      export.account.owner.members.where(role: [ "owner", "admin" ]).each do |member|
        AccountMailer.with(account: export.account, user: member.user).export_completed.deliver_later
      end
    end
  end

  def process_attachment_url(content)
    content.gsub(/\/attachments\/(?<key>[\w]+)/) do
      match = Regexp.last_match
      if attachment = Attachment.find_by(key: match[:key])
        Rails.application.routes.url_helpers.attachment_url(attachment.key)
      else
        match[0]
      end
    end
  end
end
