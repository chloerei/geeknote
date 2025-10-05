class Dashboard::Analytics::HomeController < Dashboard::Analytics::BaseController
  def index
    @period = params[:period].in?(%w[7d 30d 90d]) ? params[:period] : "7d"

    case @period
    when "7d"
      @post_views_data = fetch_post_views_data(7)
      @top_posts = fetch_top_posts(7)
    when "30d"
      @post_views_data = fetch_post_views_data(30)
      @top_posts = fetch_top_posts(30)
    when "90d"
      @post_views_data = fetch_post_views_data(90)
      @top_posts = fetch_top_posts(90)
    end
  end

  private

  def fetch_post_views_data(days)
    Ahoy::Event.where_event("post_view", account_id: @account.id)
      .group_by_day(:time, last: days)
      .count
  end

  def fetch_top_posts(days)
    @account.posts
      .joins("INNER JOIN ahoy_events ON ahoy_events.properties->>'post_id' = CAST(posts.id AS TEXT)")
      .where("ahoy_events.name = ?", "post_view")
      .where("ahoy_events.time >= ?", days.days.ago.beginning_of_day)
      .group("posts.id")
      .select("posts.id, posts.title, COUNT(ahoy_events.id) AS period_views_count")
      .order("period_views_count DESC")
      .limit(5)
  end
end
