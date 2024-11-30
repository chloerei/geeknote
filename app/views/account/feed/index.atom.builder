atom_feed(root_url: account_root_url(@account.name), id: account_root_url(@account.name)) do |feed|
  feed.title @account.display_name
  feed.subtitle @account.description
  feed.icon avatar_url(@account.owner)
  if @posts.any?
    feed.updated(@posts.maximum(:updated_at))
  end
  feed.author do |author|
    author.name @account.name
    author.uri account_root_url(@account.name)
  end

  @posts.each do |post|
    cache post do
      feed.entry(post, url: account_post_url(post.account.name, post), id: account_post_url(post.account.name, post), published: post.published_at) do |entry|
        entry.title post.title
        entry.content(markdown_render(post.content), type: "html")
        entry.summary(post_summary(post))

        entry.author do |author|
          author.name post.user.name
          author.uri account_root_url(post.user.account.name)
        end
      end
    end
  end
end
