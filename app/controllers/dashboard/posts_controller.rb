class Dashboard::PostsController < Dashboard::BaseController
  def index
    options = {}

    @status = params[:status].presence_in(Post.statuses)
    if @status
      options[:filter] = "status = '#{@status}'"
    else
      options[:filter] = "status != 'trashed'"
    end

    @sort = params[:sort].presence_in(%w[ updated created ]) || "created"
    case @sort
    when "updated"
      options[:sort] = [ "updated_at:desc" ]
    when "created"
      options[:sort] = [ "created_at:desc" ]
    end

    posts = Current.user.posts.pagy_search(params[:q], options)

    @pagy, @posts = pagy_meilisearch(posts)
  end
end
