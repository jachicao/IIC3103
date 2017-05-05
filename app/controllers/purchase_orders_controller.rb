class PurchaseOrdersController < ApplicationController
  before_action :set_purchase_order, only: [:show, :update, :destroy]

  # GET /purchase_orders
  def index
    @purchase_orders = PurchaseOrder.all
    render json: @purchase_orders
  end

  # GET /purchase_orders/1
  def show
    render json: @purchase_order
  end
  # PATCH /purchase_orders/1/acepted
  def acepted
    if params[:token].present?
      render json: '{"orderId": "qsda1", "created_at": "2017-04-26T17:03:36.154Z","channel": "b2b","supplier": "grupo 1","client": "grupo 2", "Sku": "atf1233","quantity": 2, "dispatchedQuantity": "0","unitPrice": 3000, "Deadline": "17 / 10 / 2017", "state": "acepted", "Notes": "In progress","billId": "sck2"}', status: 202
    else
      render json: {"error": "Token needed" }, status: 403
    end
  end

  # PATCH /purchase_orders/1/rejected
  def rejected
    if params[:token].present?
      render json: '{"orderId": "qsda1", "created_at": "2017-04-26T17:03:36.154Z","channel": "b2b","supplier": "grupo 1","client": "grupo 2", "Sku": "atf1233","quantity": 2, "dispatchedQuantity": "0","unitPrice": 3000, "Deadline": "17 / 10 / 2017", "state": "rejected", "Notes": "In progress","billId": "sck2"}', status: 202
    else
      render json: {"error": "Token needed" }, status: 403
    end
  end

  # PUT /purchase_orders
  def create
    #@purchase_order = PurchaseOrder.new(purchase_order_params)

    #if @purchase_order.save
    if params[:token].present?
      render json: '{"orderId": "qsda1", "created_at": "2017-04-26T17:03:36.154Z","channel": "b2b","supplier": "grupo 1","client": "grupo 2", "Sku": "atf1233","quantity": 2, "dispatchedQuantity": "0","unitPrice": 3000, "Deadline": "17 / 10 / 2017", "state": "created", "Notes": "In progress","billId": "sck2"}', status: 202, location: @purchase_order
    else
      render json: {"error": "Token needed" }, status: 403
    end
    #else
    #  render json: {error: 'Incomplete order data'}, status: 400
    #end
  end

  # /purchase_orders/1
  def update
    if @purchase_order.update(purchase_order_params)
      render json: @purchase_order
    else
      render json: @purchase_order.errors, status: :unprocessable_entity
    end
  end

  # DELETE /purchase_orders/1
  def destroy
    #if(params[:orderId].present?)
    if params[:token].present?
      render json: { "cancelled": 'Order qsda1 cancelled'}, status: 202
    else
      render json: {"error": "Token needed" }, status: 403
    end
    #else
    #  render json: {error: 'Order id not found'}, status: 404
    #end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_purchase_order
      @purchase_order = PurchaseOrder.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def purchase_order_params
      params.require(:purchase_order).permit(:orderId, :channel, :supplier, :client, :Sku, :quantity, :dispatchedQuantity, :unitPrice, :deadline, :state, :rejectionCause, :CancellationCause, :notes, :billId)
    end
end
