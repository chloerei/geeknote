class UserMailer < ApplicationMailer
  helper :application

  def password_reset_email
    @user = params[:user]

    mail(
      to: @user.email,
      subject: I18n.t('email.reset_your_geeknote_password')
    )
  end

  def post_restricted_email
    @user = params[:user]
    @post = params[:post]

    mail(
      to: @user.email,
      reply_to: 'support@geeknote.net',
      subject: I18n.t('email.your_post_is_been_restricted_for_publish')
    )
  end

  def email_verification
    @user = params[:user]

    mail(
      to: @user.email,
      reply_to: 'support@geeknote.net',
      subject: I18n.t('email.email_verification')
    )
  end

  def comment_notification
    @user = params[:user]
    @comment = params[:comment]

    mail(
      to: @user.email,
      from: "#{@comment.user.name} <notifications@geeknote.net>",
      subject: "Re: #{@comment.commentable.title}"
    )
  end
end
