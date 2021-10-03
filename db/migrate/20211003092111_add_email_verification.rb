class AddEmailVerification < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :email_verified_at, :datetime
  end
end
