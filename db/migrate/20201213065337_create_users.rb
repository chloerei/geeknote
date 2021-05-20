class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    enable_extension 'citext'

    create_table :users do |t|
      t.string :name, null: false
      t.citext :email, null: false
      t.text :bio
      t.string :password_digest
      t.string :auth_token, null: false
      t.integer :followings_count, default: 0

      t.timestamps

      t.index :email, unique: true
    end
  end
end
