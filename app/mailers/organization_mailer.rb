class OrganizationMailer < ApplicationMailer
  def invitation_email
    @member = params[:member]

    email = @member.user ? @member.user.email : @member.invitation_email

    mail(to: email, subject: "@#{@member.inviter.account.name} has invite you to join @#{@member.organization.account.name} organization")
  end
end
