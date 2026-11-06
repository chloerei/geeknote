class Account::SeriesController < Account::BaseController
  def index
    series = @account.series.order(updated_at: :desc)

    @pagy, @series = pagy(:offset, series.includes(:account))

    @page_titles.prepend t("general.series")
  end

  def show
    @series = @account.series.find(params[:id])
    posts = @series.posts.published.order(position: :asc)

    @pagy, @posts = pagy(:offset, posts)

    @page_titles.prepend @series.title
  end
end
