class CreateJoinTableJobsContacts < ActiveRecord::Migration
  def change
    create_join_table :jobs, :contacts
  end
end
