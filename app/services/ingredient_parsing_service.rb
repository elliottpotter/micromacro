class IngredientParsingService
  attr_reader :macros_text, :branded_item_matches, :calories, :protein, :carbs, :fat

  require 'string/similarity'

  API_URL = 'https://trackapi.nutritionix.com/v2'
  HEADERS = {
    'Content-Type' => 'application/json',
    'x-app-id' => '15bec601',
    'x-app-key' => ENV['NUTRITION_API_KEY'],
    'x-remote-user-id' => '0'
  }

  def initialize(lines:, branded_lines:)
    @branded_item_matches = []
    @calories = 0
    @protein = 0
    @carbs = 0
    @fat = 0

    @lines = lines 
    @branded_lines = branded_lines
  end

  def calculate
    calculate_normal_lines if @lines.present?
    calculate_branded_lines if @branded_lines.present?

    @macros_text = "Calories: #{@calories}\n\n🏋️‍♀️ Protein: #{@protein}g\n🍞 Carbs: #{@carbs}g\n🥑 Fat: #{@fat}g"
  end

  def calculate_normal_lines    
    url = "#{API_URL}/natural/nutrients"
    body = { "query" => @lines.join("\n") }.to_json

    response = Faraday.post(url, body, HEADERS)
    foods = JSON.parse(response.body)['foods']

    add_found_foods(foods) if foods
  end

  def calculate_branded_lines
    results = []
    
    @branded_lines.each do |branded_line|
      line = branded_line.gsub(/^b /, '')
      ordered_line = line.split.sort.join(' ')
      url = "#{API_URL}/search/instant?branded=true&common=false&query=#{line}"
            
      response = Faraday.get(url, {}, HEADERS)
      branded_items = JSON.parse(response.body)['branded']

      branded_items.each do |branded_item|
        id = branded_item['nix_item_id']
        name = branded_item['brand_name_item_name']
        amount = branded_item['serving_qty']
        unit = branded_item['serving_unit']
        ordered_name = name.split.sort.join(' ')

        distance = String::Similarity.levenshtein_distance(ordered_line, ordered_name)
        results << { id: id, name: name, amount: amount, unit: unit, distance: distance }        
      end

      top_result = results.sort_by {|result| result[:distance]}[0]
      @branded_item_matches << "#{top_result[:amount]} #{top_result[:unit]} #{top_result[:name]}"
      calculate_top_result(top_result[:id])
    end 
  end 

  def calculate_top_result(id)
    url = "#{API_URL}/search/item?nix_item_id=#{id}"
    response = Faraday.get(url, {}, HEADERS)
    foods = JSON.parse(response.body)['foods']
    
    add_found_foods(foods) if foods
  end

  def add_found_foods(foods)
    foods.each do |food|
      @calories += food['nf_calories'].to_f.round
      @protein += food['nf_protein'].to_f.round
      @carbs += food['nf_total_carbohydrate'].to_f.round
      @fat += food['nf_total_fat'].to_f.round
    end 
  end
end
