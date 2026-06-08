class Dashboard::SeriesController < Dashboard::BaseController
  def index
    series = @account.series.order(updated_at: :desc)

    @pagy, @series = pagy(series)

    @page_titles.prepend t("general.series")
  end

  def show
    @series = @account.series.find(params[:id])
    @posts = @series.posts.order(position: :asc)
    # @pagy, @posts = pagy(posts)

    @page_titles.prepend @series.title
  end

  def new
    @series = @account.series.new
    @page_titles.prepend t("general.new_series")
  end

  def create
    @series = @account.series.new(series_params)

    if @series.save
      redirect_to dashboard_series_index_path(@account.name), notice: t(".success")
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    @series = @account.series.find(params[:id])
    @page_titles.prepend t("general.edit_series")
  end

  def update
    @series = @account.series.find(params[:id])

    if @series.update(series_params)
      redirect_to dashboard_series_index_path(@account.name), notice: t(".success")
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @series = @account.series.find(params[:id])
    @series.destroy
    redirect_to dashboard_series_index_path(@account.name), notice: t(".success")
  end

  private

  def series_params
    params.require(:series).permit(:title, :description, :add_new_at)
  end
end
