class CreateDepartments < ActiveRecord::Migration[7.1]
  def change
    create_table :departments do |t|
      t.string :name
      t.string :code
      t.references :headquarter, null: false, foreign_key: true

      t.timestamps
    end
  end
end
