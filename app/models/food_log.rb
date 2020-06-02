class FoodLog < ApplicationRecord
  belongs_to :user
  belongs_to :request, required: false
end
