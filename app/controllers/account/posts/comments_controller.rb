class Account::Posts::CommentsController < Account::Posts::BaseController
  def index
    comments = @post.comments

    @sort = params[:sort].presence_in(%w[ oldest popular ]) || "newest"

    comments = case @sort
    when "oldest"
      comments.order(created_at: :asc)
    when "popular"
      comments.popular
    else
      comments.order(created_at: :desc)
    end

    @pagy, @comments = pagy(comments, page: params[:page])
  end
end
