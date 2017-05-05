require 'test_helper'

class StoreHousesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @store_house = store_houses(:one)
  end

  test "should get index" do
    get store_houses_url
    assert_response :success
  end

  test "should get new" do
    get new_store_house_url
    assert_response :success
  end

  test "should create store_house" do
    assert_difference('StoreHouse.count') do
      post store_houses_url, params: { store_house: { dispatch: @store_house.dispatch, external: @store_house.external, reception: @store_house.reception, totalSpace: @store_house.totalSpace, usedSpace: @store_house.usedSpace } }
    end

    assert_redirected_to store_house_url(StoreHouse.last)
  end

  test "should show store_house" do
    get store_house_url(@store_house)
    assert_response :success
  end

  test "should get edit" do
    get edit_store_house_url(@store_house)
    assert_response :success
  end

  test "should update store_house" do
    patch store_house_url(@store_house), params: { store_house: { dispatch: @store_house.dispatch, external: @store_house.external, reception: @store_house.reception, totalSpace: @store_house.totalSpace, usedSpace: @store_house.usedSpace } }
    assert_redirected_to store_house_url(@store_house)
  end

  test "should destroy store_house" do
    assert_difference('StoreHouse.count', -1) do
      delete store_house_url(@store_house)
    end

    assert_redirected_to store_houses_url
  end
end
