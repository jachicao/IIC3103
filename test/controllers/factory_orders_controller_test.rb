require 'test_helper'

class FactoryOrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @factory_order = factory_orders(:one)
  end

  test "should get index" do
    get factory_orders_url
    assert_response :success
  end

  test "should get new" do
    get new_factory_order_url
    assert_response :success
  end

  test "should create factory_order" do
    assert_difference('FactoryOrder.count') do
      post factory_orders_url, params: { factory_order: { available: @factory_order.available, dispatched: @factory_order.dispatched, fo_id: @factory_order.fo_id, group: @factory_order.group, quantity: @factory_order.quantity, sku: @factory_order.sku } }
    end

    assert_redirected_to factory_order_url(FactoryOrder.last)
  end

  test "should show factory_order" do
    get factory_order_url(@factory_order)
    assert_response :success
  end

  test "should get edit" do
    get edit_factory_order_url(@factory_order)
    assert_response :success
  end

  test "should update factory_order" do
    patch factory_order_url(@factory_order), params: { factory_order: { available: @factory_order.available, dispatched: @factory_order.dispatched, fo_id: @factory_order.fo_id, group: @factory_order.group, quantity: @factory_order.quantity, sku: @factory_order.sku } }
    assert_redirected_to factory_order_url(@factory_order)
  end

  test "should destroy factory_order" do
    assert_difference('FactoryOrder.count', -1) do
      delete factory_order_url(@factory_order)
    end

    assert_redirected_to factory_orders_url
  end
end
