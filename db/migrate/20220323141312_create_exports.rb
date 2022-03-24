class CreateExports < ActiveRecord::Migration[7.0]
  def change
    create_table :exports do |t|
      t.belongs_to :account
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
