require 'test_helper'

class PurchaseOrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @purchase_order = purchase_orders(:one)
  end

  test "should get index" do
    get purchase_orders_url
    assert_response :success
  end

  test "should get new" do
    get new_purchase_order_url
    assert_response :success
  end

  test "should create purchase_order" do
    assert_difference('PurchaseOrder.count') do
      post purchase_orders_url, params: { purchase_order: { billId: @purchase_order.billId, cancellationCause: @purchase_order.cancellationCause, channel: @purchase_order.channel, client: @purchase_order.client, deadline: @purchase_order.deadline, dispatchedQuantity: @purchase_order.dispatchedQuantity, notes: @purchase_order.notes, orderId: @purchase_order.orderId, quantity: @purchase_order.quantity, rejectionCause: @purchase_order.rejectionCause, sku: @purchase_order.sku, state: @purchase_order.state, supplier: @purchase_order.supplier, unitPrice: @purchase_order.unitPrice } }
    end

    assert_redirected_to purchase_order_url(PurchaseOrder.last)
  end

  test "should show purchase_order" do
    get purchase_order_url(@purchase_order)
    assert_response :success
  end

  test "should get edit" do
    get edit_purchase_order_url(@purchase_order)
    assert_response :success
  end

  test "should update purchase_order" do
    patch purchase_order_url(@purchase_order), params: { purchase_order: { billId: @purchase_order.billId, cancellationCause: @purchase_order.cancellationCause, channel: @purchase_order.channel, client: @purchase_order.client, deadline: @purchase_order.deadline, dispatchedQuantity: @purchase_order.dispatchedQuantity, notes: @purchase_order.notes, orderId: @purchase_order.orderId, quantity: @purchase_order.quantity, rejectionCause: @purchase_order.rejectionCause, sku: @purchase_order.sku, state: @purchase_order.state, supplier: @purchase_order.supplier, unitPrice: @purchase_order.unitPrice } }
    assert_redirected_to purchase_order_url(@purchase_order)
  end

  test "should destroy purchase_order" do
    assert_difference('PurchaseOrder.count', -1) do
      delete purchase_order_url(@purchase_order)
    end

    assert_redirected_to purchase_orders_url
  end
end
