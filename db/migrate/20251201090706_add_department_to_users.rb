class AddDepartmentToUsers < ActiveRecord::Migration[7.1]
  def change
    add_reference :users, :department, null: false, foreign_key: true, after: :id
  end
end