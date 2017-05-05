require 'test_helper'

class PurchaseOrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @purchase_order = purchase_orders(:one)
  end

  test "should get index" do
    get purchase_orders_url, as: :json
    assert_response :success
  end

  test "should create purchase_order" do
    assert_difference('PurchaseOrder.count') do
      post purchase_orders_url, params: { purchase_order: { CancellationCause: @purchase_order.CancellationCause, Sku: @purchase_order.Sku, billId: @purchase_order.billId, channel: @purchase_order.channel, client: @purchase_order.client, deadline: @purchase_order.deadline, dispatchedQuantity: @purchase_order.dispatchedQuantity, notes: @purchase_order.notes, orderId: @purchase_order.orderId, quantity: @purchase_order.quantity, rejectionCause: @purchase_order.rejectionCause, state: @purchase_order.state, supplier: @purchase_order.supplier, unitPrice: @purchase_order.unitPrice } }, as: :json
    end

    assert_response 201
  end

  test "should show purchase_order" do
    get purchase_order_url(@purchase_order), as: :json
    assert_response :success
  end

  test "should update purchase_order" do
    patch purchase_order_url(@purchase_order), params: { purchase_order: { CancellationCause: @purchase_order.CancellationCause, Sku: @purchase_order.Sku, billId: @purchase_order.billId, channel: @purchase_order.channel, client: @purchase_order.client, deadline: @purchase_order.deadline, dispatchedQuantity: @purchase_order.dispatchedQuantity, notes: @purchase_order.notes, orderId: @purchase_order.orderId, quantity: @purchase_order.quantity, rejectionCause: @purchase_order.rejectionCause, state: @purchase_order.state, supplier: @purchase_order.supplier, unitPrice: @purchase_order.unitPrice } }, as: :json
    assert_response 200
  end

  test "should destroy purchase_order" do
    assert_difference('PurchaseOrder.count', -1) do
      delete purchase_order_url(@purchase_order), as: :json
    end

    assert_response 204
  end
end
