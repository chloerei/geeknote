# Preview all emails at http://localhost:3000/rails/mailers/organization_mailer
class OrganizationMailerPreview < ActionMailer::Preview
  def invitation_user
    membership = Membership.invitations.last
    OrganizationMailer.with(membership: membership).invitation_email
  end
end
