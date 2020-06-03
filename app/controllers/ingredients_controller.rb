class IngredientsController < ApplicationController
  before_action :set_user, :create_request
  
  def parse
    
    # binding.pry
    
    query = ingredients_params[:Body].downcase.strip

    service = NutritionIntelligenceService.new(
      query: query, 
      user: @user, 
      new_user: @new_user, 
      request: @request
    )
    service.converse!
  end

  private

  def create_request
    @request = Request.create(parameters: params)
  end

  def set_user 
    @user = User.find_or_initialize_by(phone_number: ingredients_params[:From])

    if @user.new_record?
      @user.save 
      @new_user = true
    end
    @user
  end

  def ingredients_params
    params.permit(:ingredient, :Body, :From, :FromCity, :FromState)
  end
  
end
