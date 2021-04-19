class CreateMemberships < ActiveRecord::Migration[6.1]
  def change
    create_table :memberships do |t|
      t.belongs_to :organization
      t.belongs_to :user
      t.integer :role, null: false

      t.timestamps
    end
  end
end
