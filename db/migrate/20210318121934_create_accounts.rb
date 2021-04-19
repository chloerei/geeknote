class CreateAccounts < ActiveRecord::Migration[6.1]
  def change
    create_table :accounts do |t|
      t.citext :path
      t.belongs_to :owner, polymorphic: true

      t.timestamps

      t.index :path, unique: true
    end
  end
end
