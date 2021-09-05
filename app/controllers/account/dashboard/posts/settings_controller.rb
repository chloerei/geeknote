class Account::Dashboard::Posts::SettingsController < Account::Dashboard::Posts::BaseController
  layout 'base'

  def show
  end

  def update
    parsed_params = settings_params

    parsed_params[:tag_list] ||= []
    parsed_params[:author_list] ||= []

    if @post.update parsed_params
      redirect_to account_dashboard_post_settings_path(@account, @post), notice: I18n.t('flash.post_settings_updated')
    else
      render turbo_stream: turbo_stream.replace('settings-form', partial: 'form')
    end
  end

  private

  def settings_params
    if @account.user?
      params.require(:post).permit(:excerpt, :allow_comments, :featured, tag_list: [])
    else
      params.require(:post).permit(:excerpt, :allow_comments, :featured, tag_list: [], author_list: [])
    end
  end
end
