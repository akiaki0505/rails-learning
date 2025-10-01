require "test_helper"

class WorldControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get world_index_url
    assert_response :success
  end
end
