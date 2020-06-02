class AddRequestToFoodLogs < ActiveRecord::Migration[6.0]
  def change
    add_reference :food_logs, :request, null: false, foreign_key: true
  end
end
