class AddSomeDataToUsers < ActiveRecord::Migration
  def change
    add_column :users, :first_name, :string,  null: false
    add_column :users, :last_name,  :string,  null: false
    add_column :users, :active,     :boolean, default: true
    add_column :users, :admin,      :boolean, default: false
  end
end
