class NutritionIntelligenceService
  attr_reader :text_body

  WELCOME_TEXT = "Hi there 👋! I'm Mr. Macro, your personal nutrition assistant.\n\nSay things like:\n2 eggs\n1 cup of spinach to get instant nutrition info on the things you eat.\n\nYou can also being a message with \"log\" and I'll record that item for you, then give you a breakdown of your nutrition the next morning.\n\nFor branded items, start the line with a \"B \", like \"b Chobani vanilla yogurt"

  def initialize(query: query, user: user, new_user: false, request: request)
    @text_body = ''
    @query     = query
    @lines     = query.split("\n")
    @new_user  = new_user
    @user      = user
    @request   = request
  end

  def converse!
    return TextingService.send(to: @user.phone_number, body: WELCOME_TEXT) if @new_user
    return send_today_logs if @query == 'today'
    return send_today_logs(true) if @query == '24'
    return create_manual_log if @query =~ /log macro/
    return undo_last_log if @query =~ /^undo$/

    get_macros_from_query
    TextingService.send(to: @user.phone_number, body: @text_body)
  end

  def get_macros_from_query
    lines = @query.split("\n")
    brand_lines = lines.select { |line| line.match(/^(b )/) }
    lines.reject! { |line| brand_lines.index(line) }
    lines = lines.map { |line| line.gsub(/^log /, '').strip }
    brand_lines = brand_lines.map { |line| line.gsub(/^b /, '').strip }
  
    service = IngredientParsingService.new(lines: lines, branded_lines: brand_lines)
    service.calculate

    @text_body << "Found branded items: #{service.branded_item_matches.join(', ')}\n\n" if service.branded_item_matches.present?
    @text_body << service.macros_text

    if @query.match(/^log /)
      create_food_log(service)
      @text_body.prepend("Got it. I logged this for you:\n\n")
    end
  end

  def undo_last_log
    log = FoodLog.from_today.where(user: @user).last

    if log
      @text_body = "You got it! 🗑 I removed this log:\n\n⚡️ Calories: #{log.calories}\n🏋️‍♀️ Protein: #{log.protein}g\n🍞 Carbs: #{log.carbohydrates}g\n🥑 Fat: #{log.fat}g"
      log.destroy
    else 
      @text_body = "Oops! You don't have any more logs from today to delete."
    end

    TextingService.send(to: @user.phone_number, body: @text_body)
  end
  
  def create_manual_log    
    ob = OpenStruct.new(
      calories: @lines.find { |l| l =~ /cal/ }.scan(/\d+/)[0],
      protein: @lines.find { |l| l =~ /pro/ }.scan(/\d+/)[0],
      carbs: @lines.find { |l| l =~ /carb/ }.scan(/\d+/)[0],
      fat: @lines.find { |l| l =~ /fat/ }.scan(/\d+/)[0],
    )
    create_food_log(ob)
    @text_body = "Ok! I logged this for you:\n\n⚡️ Calories: #{ob.calories}\n🏋️‍♀️ Protein: #{ob.protein}g\n🍞 Carbs: #{ob.carbs}g\n🥑 Fat: #{ob.fat}g"

    TextingService.send(to: @user.phone_number, body: @text_body)
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

  def send_today_logs(day = false)
    logs = day ? FoodLog.day.where(@user: user) : FoodLog.from_today.where(user: @user)
    calories = logs.pluck(:calories).reduce(:+)
    protein = logs.pluck(:protein).reduce(:+)
    carbs = logs.pluck(:carbohydrates).reduce(:+)
    fat = logs.pluck(:fat).reduce(:+)

    body = "Today's totals so far:\n\n⚡️ Calories: #{calories}\n🏋️‍♀️ Protein: #{protein}g\n🍞 Carbs: #{carbs}g\n🥑 Fat: #{fat}g"
    TextingService.send(to: @user.phone_number, body: body)
  end
end

