class Request < ApplicationRecord
  has_one :food_log, required: false
end
