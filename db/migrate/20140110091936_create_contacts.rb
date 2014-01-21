class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.boolean :active, default: true
      t.string :civility, limit: 4, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.date :date_of_birth, null: false

      t.string :address, null: false
      t.string :zip_code, null: false
      t.string :city, null: false

      t.string :phone_number, limit: 10
      t.string :mobile_number, limit: 10

      t.string :email, null: false

      t.string :photo
      t.string :website
      t.text :comment

      t.timestamps
    end
    add_index :contacts, :email, unique: true
  end
end
