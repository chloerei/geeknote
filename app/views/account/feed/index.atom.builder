atom_feed(root_url: account_root_url(@account), id: account_root_url(@account)) do |feed|
  feed.title @account.display_name
  feed.subtitle @account.description
  feed.icon avatar_url(@account.owner.avatar)
  if @posts.any?
    feed.updated(@posts[0].published_at)
  end
  feed.author do |author|
    author.name @account.name
    author.uri account_root_url(@account)
  end


  @posts.each do |post|
    feed.entry(post, url: account_post_url(@account, post), id: account_post_url(@account, post), published: post.published_at) do |entry|
      entry.title post.title
      entry.content(markdown_render(post.content), type: 'html')
      entry.summary(post_summary(post))

      post.author_users.each do |user|
        entry.author do |author|
          author.name user.name
          author.uri account_root_url(user.account)
        end
      end
    end
  end
end
