# Preview all emails at http://localhost:3000/rails/mailers/account_mailer
class AccountMailerPreview < ActionMailer::Preview
  def export_completed
    @account = Account.first
    AccountMailer.with(account: @account, user: @account.owner).export_completed
  end
end
