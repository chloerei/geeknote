class Dashboard::HomeController < Dashboard::BaseController
  def index
    @posts_published = @account.posts.published
    @posts_draft = @account.posts.draft

    @total_views    = @posts_published.sum(:views_count)
    @total_likes    = @posts_published.sum(:likes_count)
    @total_comments = @posts_published.sum(:comments_count)
    @total_bookmarks = @posts_published.sum(:bookmarks_count)

    @recent_posts = @posts_published
      .order(published_at: :desc)
      .limit(5)

    @recent_drafts = @posts_draft
      .order(updated_at: :desc)
      .limit(3)
  end
end
