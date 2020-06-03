class NutritionIntelligenceService

  WELCOME_TEXT = "Hi there 👋! I'm Mr. Macro, your personal nutrition assistant.\n\nSay things like:\n2 eggs\n1 cup of spinach to get instant nutrition info on the things you eat.\n\nYou can also being a message with \"log\" and I'll record that item for you, then give you a breakdown of your nutrition the next morning.\n\nFor branded items, start the line with a \"B \", like \"b Chobani vanilla yogurt"

  def initialize(query: query, user: user, new_user: false, request: request)
    @text_body = ''
    @query     = query
    @new_user  = new_user
    @user      = user
    @request   = request
  end

  def converse!
    return TextingService.send(to: @user.phone_number, body: WELCOME_TEXT) if @new_user

    get_macros_from_query
    # TextingService.send(to: @user.phone_number, body: @text_body)
  end

  def get_macros_from_query
    lines = @query.split("\n")
    brand_lines = lines.select { |line| line.match(/^(b )/) }
    lines.reject! { |line| brand_lines.index(line) }
    lines = lines.map { |line| line.gsub(/^log /, '').strip }
  
    service = IngredientParsingService.new(lines: lines, branded_lines: brand_lines)
    service.calculate

    @text_body << "Found branded items: #{service.branded_item_matches.join(', ')}\n\n" if service.branded_item_matches.present?
    @text_body << service.macros_text

    if @query.match(/^log /)
      create_food_log(service)
      @text_body.prepend("Got it. I logged this for you:\n\n")
    end
  end

  def create_food_log(service)
    log = FoodLog.new(
      user: @user, 
      request: @request, 
      calories: service.calories, 
      protein: service.protein, 
      carbohydrates: service.carbs, 
      fat: service.fat
    )
    log.save!
  end
  
end
