class CreateFoodLogs < ActiveRecord::Migration[6.0]
  def change
    create_table :food_logs do |t|
      t.integer :calories
      t.integer :protein
      t.integer :carbohydrates
      t.integer :fat

      t.timestamps
    end
  end
end
