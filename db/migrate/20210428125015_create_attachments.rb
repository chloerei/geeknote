class CreateAttachments < ActiveRecord::Migration[6.1]
  def change
    create_table :attachments do |t|
      t.belongs_to :account
      t.belongs_to :user
      t.string :key

      t.timestamps

      t.index :key, unique: true
    end
  end
end
