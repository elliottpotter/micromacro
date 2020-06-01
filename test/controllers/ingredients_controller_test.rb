require 'test_helper'

class IngredientsControllerTest < ActionDispatch::IntegrationTest
  test "should get parse" do
    get ingredients_parse_url
    assert_response :success
  end

end
