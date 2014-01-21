class AddCountryRefToContacts < ActiveRecord::Migration
  def change
    add_reference :contacts, :country, index: true
  end
end
