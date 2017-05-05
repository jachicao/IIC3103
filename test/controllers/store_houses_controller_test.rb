require 'test_helper'

class StoreHousesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @store_house = store_houses(:one)
  end

  test "should get index" do
    get store_houses_url, as: :json
    assert_response :success
  end

  test "should create store_house" do
    assert_difference('StoreHouse.count') do
      post store_houses_url, params: { store_house: { dispatch: @store_house.dispatch, external: @store_house.external, reception: @store_house.reception, totalSpace: @store_house.totalSpace, usedSpace: @store_house.usedSpace } }, as: :json
    end

    assert_response 201
  end

  test "should show store_house" do
    get store_house_url(@store_house), as: :json
    assert_response :success
  end

  test "should update store_house" do
    patch store_house_url(@store_house), params: { store_house: { dispatch: @store_house.dispatch, external: @store_house.external, reception: @store_house.reception, totalSpace: @store_house.totalSpace, usedSpace: @store_house.usedSpace } }, as: :json
    assert_response 200
  end

  test "should destroy store_house" do
    assert_difference('StoreHouse.count', -1) do
      delete store_house_url(@store_house), as: :json
    end

    assert_response 204
  end
end
