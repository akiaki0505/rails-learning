class CreateSurveys < ActiveRecord::Migration[7.1]
  def change
    create_table :surveys do |t|
      t.integer :user_id, index: true, null: true 
      t.integer :q1, null: false
      t.integer :q2, null: false 
      t.integer :q3, null: false
      t.integer :q4, null: false
      t.integer :q5, null: false
      t.integer :total_score
      t.text :comment

      t.timestamps
    end
  end
end
