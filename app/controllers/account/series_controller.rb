class Account::SeriesController < Account::BaseController
  def index
    series = @account.series.order(updated_at: :desc)

    @pagy, @series = pagy(series.includes(:account))

    @page_titles.prepend t("general.series")
  end

  def show
    @series = @account.series.find(params[:id])
    posts = @series.posts.published.order(position: :asc)

    @pagy, @posts = pagy(posts)

    @page_titles.prepend @series.title
  end
end
