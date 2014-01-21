class CreateCountries < ActiveRecord::Migration
  def change
    create_table :countries do |t|
      t.string :code, limit: 2, null: false
      t.string :name, null:false
    end
    add_index :countries, :code, unique: true
    add_index :countries, :name, unique: true
  end
end
