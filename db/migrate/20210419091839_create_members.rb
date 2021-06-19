class CreateMembers < ActiveRecord::Migration[6.1]
  def change
    create_table :members do |t|
      t.belongs_to :organization
      t.belongs_to :user
      t.integer :role, default: 2

      t.belongs_to :inviter
      t.citext :invitation_email
      t.string :invitation_token
      t.datetime :invited_at
      t.datetime :actived_at
      t.integer :status, default: 0

      t.timestamps

      t.index [:organization_id, :user_id], unique: true
    end
  end
end
