class PurchaseOrdersController < ApplicationController
  before_action :set_purchase_order, only: [:show, :accept, :reject, :dispatch_product]

  # GET /purchase_orders
  # GET /purchase_orders.json
  def index
    @own_purchase_orders = PurchaseOrder.get_my_orders
    @received_purchase_orders = PurchaseOrder.get_client_orders.select { |v| !v.dispatched}
    @dispatched_purchase_orders = PurchaseOrder.get_client_orders.select { |v| v.dispatched}
  end

  # GET /purchase_orders/1
  # GET /purchase_orders/1.json
  def show

  end

  def dispatch_product
    result = @purchase_order.analyze_stock_to_dispatch
    respond_to do |format|
      if result == nil
        format.html { redirect_to purchase_order_url(@purchase_order), notice: 'Servidor colapsado' }
      elsif result > 0
        product = @purchase_order.get_product
        format.html { redirect_to purchase_order_url(@purchase_order), notice: 'Falta ' + result.to_s + ' de ' + product.name }
      else
        @purchase_order.dispatch_order
        format.html { redirect_to purchase_order_url(@purchase_order), notice: 'Purchase order was successfully dispatched.' }
      end
    end
  end

  def accept
    result = @purchase_order.accept_purchase_order
    respond_to do |format|
      if result[:server][:code] == 200
        format.html { redirect_to purchase_order_url(@purchase_order), notice: 'Purchase order was successfully accepted.' }
      else
        format.html { redirect_to purchase_order_url(@purchase_order), notice: 'Failed to accept: ' + result.to_json }
      end
    end
  end

  def reject
    result = @purchase_order.reject_purchase_order('causa')
    respond_to do |format|
      if result[:server][:code] == 200
        format.html { redirect_to purchase_order_url(@purchase_order), notice: 'Purchase order was successfully rejected.' }
      else
        format.html { redirect_to purchase_order_url(@purchase_order), notice: 'Failed to reject: ' + result.to_json }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_purchase_order
      @purchase_order = PurchaseOrder.find(params[:id])
      response = PurchaseOrder.get_server_details(@purchase_order.po_id)
      case response[:code]
        when 200
          @server_body = response[:body]
        else
          return render :json => { :error => response[:body] }, status: response[:code]
      end
    end
end
