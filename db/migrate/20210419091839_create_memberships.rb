class CreateMemberships < ActiveRecord::Migration[6.1]
  def change
    create_table :memberships do |t|
      t.belongs_to :organization
      t.belongs_to :user
      t.integer :role

      t.citext :invite_email
      t.string :invite_token
      t.datetime :invited_at
      t.datetime :actived_at
      t.integer :status, default: 0

      t.timestamps

      t.index [:organization_id, :user_id], unique: true
    end
  end
end
