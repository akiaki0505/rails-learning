class CreateEmployees < ActiveRecord::Migration[7.1]
  def change
    create_table :employees do |t|
      t.string :employee_number
      t.string :name
      t.string :email
      t.string :department_name

      t.timestamps
    end
  end
end
