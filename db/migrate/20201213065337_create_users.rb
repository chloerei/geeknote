class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.text :bio
      t.string :password_digest
      t.string :auth_token, null: false

      t.timestamps

      t.index 'lower(email)', unique: true
    end
  end
end
