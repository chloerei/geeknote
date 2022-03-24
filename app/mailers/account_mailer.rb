class AccountMailer < ApplicationMailer
  def export_completed
    @account = params[:account]
    @user = params[:user]

    mail(to: @user.email, subject: I18n.t('mailer.account_mailer.export_complted_subject', account_name: @account.name))
  end
end
