class IngredientsController < ApplicationController
  
  def parse
    url = 'https://api.spoonacular.com/recipes/parseIngredients?apiKey=1492765f663c43eba2d2de9697a587a0'
    resp = Faraday.post(url, "ingredientList=#{ingredients_params[:Body]}&includeNutrition=true")
    ingredients = JSON.parse(resp.body)

    calories = 0
    protein = 0
    carbs = 0
    fat = 0

    ingredients.each do |ingredient|
      nutrients = ingredient['nutrition']['nutrients']

      calories += nutrients.find {|n| n['title'] == 'Calories' }['amount'].to_f.round
      protein += nutrients.find {|n| n['title'] == 'Protein' }['amount'].to_f.round
      carbs += nutrients.find {|n| n['title'] == 'Carbohydrates' }['amount'].to_f.round
      fat += nutrients.find {|n| n['title'] == 'Fat' }['amount'].to_f.round
    end 

    text_body = "Calories: #{calories}\n\n🏋️‍♀️Protein: #{protein}g\n🍞Carbs: #{carbs}g\n🥑Fat: #{fat}g"
    
    client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_ID'], ENV['TWILIO_AUTH_TOKEN'])
    params = {
      messaging_service_sid: ENV['TWILIO_MESSAGING_SERVICE_SID'],
      from: '+12052364969',
      to: ingredients_params[:From],
      body: text_body
    }

    client.messages.create(params)
  end

  def ingredients_params
    params.permit(:ingredient, :Body, :From)
  end
  
end
