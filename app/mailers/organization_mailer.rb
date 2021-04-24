class OrganizationMailer < ApplicationMailer
  def invitation_email
    @membership = params[:membership]

    email = @membership.user ? @membership.user.email : @membership.invitation_email

    mail(to: email, subject: "@#{@membership.inviter.account.name} has invite you to join @#{@membership.organization.account.name} organization")
  end
end
