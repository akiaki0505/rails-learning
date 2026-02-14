class AddCompanyAndDepartmentToEmployees < ActiveRecord::Migration[7.1]
  def change
    add_reference :employees, :company, null: true
    add_reference :employees, :department, null: true
  end
end
