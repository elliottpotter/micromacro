class CreateRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :requests do |t|
      t.json :parameters
      t.string :response_body

      t.timestamps
    end
  end
end
