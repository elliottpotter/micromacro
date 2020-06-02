class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :phone_number
      t.integer :calorie_goal
      t.integer :protein_goal
      t.integer :carbohydrate_goal
      t.integer :fat_goal

      t.timestamps
    end
  end
end
