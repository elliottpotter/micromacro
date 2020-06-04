class FoodLog < ApplicationRecord
  belongs_to :user
  belongs_to :request, required: false

  scope :from_today, -> { where("created_at > ?", (Time.now - (DateTime.now.in_time_zone("Central Time (US & Canada)").beginning_of_day + 5.hours)).seconds.ago) }
end
