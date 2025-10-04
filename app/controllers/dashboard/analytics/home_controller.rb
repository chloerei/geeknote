class Dashboard::Analytics::HomeController < Dashboard::Analytics::BaseController
  def index
    day = 7

    @post_views_data = Ahoy::Event.where_event("post_view", account_id: @account.id).group_by_day(:time, last: day).count

    @top_posts = @account.posts
      .joins("INNER JOIN ahoy_events ON ahoy_events.properties->>'post_id' = CAST(posts.id AS TEXT)")
      .where("ahoy_events.name = ?", "post_view")
      .where("ahoy_events.time >= ?", day.days.ago.beginning_of_day)
      .group("posts.id")
      .select("posts.*, COUNT(ahoy_events.id) AS range_views_count")
      .order("range_views_count DESC")
      .limit(5)
  end
end
