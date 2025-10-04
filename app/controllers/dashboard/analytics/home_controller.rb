class Dashboard::Analytics::HomeController < Dashboard::Analytics::BaseController
  def index
    @post_views_data = Ahoy::Event.where_event("post_view", account_id: @account.id).group_by_day(:time, last: 7).count
    @references_data = Ahoy::Visit.where(id: Ahoy::Event.where_event("post_view", account_id: @account.id).select(:visit_id)).group(:referrer).order("count_all DESC").limit(5).count
  end
end
