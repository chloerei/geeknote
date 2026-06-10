class Dashboard::Series::BaseController < Dashboard::BaseController
  before_action :set_series

  private

  def set_series
    @series = @account.series.find(params[:series_id])
  end
end
