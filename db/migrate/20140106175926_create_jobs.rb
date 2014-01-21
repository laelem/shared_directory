class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.string :name, null: false
      t.boolean :active, null: false

      t.timestamps
    end
    add_index :jobs, :name, unique: true
  end
end
