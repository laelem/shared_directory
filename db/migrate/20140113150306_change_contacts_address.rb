class ChangeContactsAddress < ActiveRecord::Migration
  def change
    change_column :contacts, :address, :string, null: true
    change_column :contacts, :zip_code, :string, null: true, limit: 5
    change_column :contacts, :city, :string, null: true
  end
end
