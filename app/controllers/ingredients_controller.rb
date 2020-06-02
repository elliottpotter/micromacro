class IngredientsController < ApplicationController
  
  def parse
    if !(ingredients_params[:Body] == 'Req')
      url = 'https://trackapi.nutritionix.com/v2/natural/nutrients'
      headers = {
        'Content-Type' => 'application/json',
        'x-app-id' => '15bec601',
        'x-app-key' => ENV['NUTRITION_API_KEY'],
        'x-remote-user-id' => '0'
      }

      resp = Faraday.post(url, {"query" => ingredients_params[:Body]}.to_json, headers)
      foods = JSON.parse(resp.body)['foods']
      
      calories = 0
      protein = 0
      carbs = 0
      fat = 0

      foods.each do |food|
        calories += food['nf_calories'].to_f.round
        protein += food['nf_protein'].to_f.round
        carbs += food['nf_total_carbohydrate'].to_f.round
        fat += food['nf_total_fat'].to_f.round
      end 

      text_body = "Calories: #{calories}\n\n🏋️‍♀️ Protein: #{protein}g\n🍞 Carbs: #{carbs}g\n🥑 Fat: #{fat}g"
      puts "RESULT FOR #{ingredients_params[:Body]}\n\n#{text_body}\n\nsent from: #{ingredients_params[:From]} in #{ingredients_params[:FromCity].capitalize}, #{ingredients_params[:FromState]}"
    else 
      text_body = requests
    end

    client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_ID'], ENV['TWILIO_AUTH_TOKEN'])
    params = {
      from: '+12052364969',
      to: ingredients_params[:From],
      body: text_body
    }

    client.messages.create(params)

    Request.create(parameters: params, response_body: text_body) unless ingredients_params[:Body] == 'Req'
  end

  def requests
    results = []
    Request.where("created_at > ?", 12.hours.ago).each do |req|
      results << {
        "time" => "#{((Time.now - req.created_at) / 1.hour).round(1)} hours ago",
        "number" => req.parameters['From'],
        "place" => "#{req.parameters['FromCity'].capitalize}, #{req.parameters['FromState']}",
        "query" => req.parameters['Body']
      }
    end

    body = ""
    results.each { |d| body += "#{d['time']} hours ago #{d['number']} from #{d['place']} sent: #{d['query']}\n" }
    body
  end

  def get_today_totals
    FoodLog.where("created_at > ?", Time.now - DateTime.now.in_time_zone("Central Time (US & Canada)").beginning_of_day)
  end
  

  def ingredients_params
    params.permit(:ingredient, :Body, :From, :FromCity, :FromState)
  end
  
end
