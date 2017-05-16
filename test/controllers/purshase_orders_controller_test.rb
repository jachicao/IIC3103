require 'test_helper'

class PurshaseOrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @purshase_order = purshase_orders(:one)
  end

  test "should get index" do
    get purshase_orders_url
    assert_response :success
  end

  test "should get new" do
    get new_purshase_order_url
    assert_response :success
  end

  test "should create purshase_order" do
    assert_difference('PurshaseOrder.count') do
      post purshase_orders_url, params: { purshase_order: {  } }
    end

    assert_redirected_to purshase_order_url(PurshaseOrder.last)
  end

  test "should show purshase_order" do
    get purshase_order_url(@purshase_order)
    assert_response :success
  end

  test "should get edit" do
    get edit_purshase_order_url(@purshase_order)
    assert_response :success
  end

  test "should update purshase_order" do
    patch purshase_order_url(@purshase_order), params: { purshase_order: {  } }
    assert_redirected_to purshase_order_url(@purshase_order)
  end

  test "should destroy purshase_order" do
    assert_difference('PurshaseOrder.count', -1) do
      delete purshase_order_url(@purshase_order)
    end

    assert_redirected_to purshase_orders_url
  end
end
