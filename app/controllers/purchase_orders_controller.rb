class PurchaseOrdersController < ApplicationController
  before_action :set_purchase_order, only: [:show, :accept, :reject, :destroy, :create_invoice]

  # GET /purchase_orders
  # GET /purchase_orders.json
  def index
    @own_purchase_orders = PurchaseOrder.get_my_orders.select { |v| !(v.is_rejected or v.is_cancelled) }
    @received_purchase_orders = PurchaseOrder.get_client_orders.select { |v| !(v.is_dispatched) and !(v.is_rejected or v.is_cancelled) }
    @dispatched_purchase_orders = PurchaseOrder.get_client_orders.select { |v| v.is_dispatched and !(v.is_rejected or v.is_cancelled) }
  end

  # GET /purchase_orders/1
  # GET /purchase_orders/1.json
  def show
  end

  def accept
    result = @purchase_order.accept
    respond_to do |format|
      if result[:server][:code] == 200
        format.html { redirect_to purchase_order_url(@purchase_order), notice: 'Purchase order was successfully accepted.' }
      else
        format.html { redirect_to purchase_order_url(@purchase_order), notice: 'Failed to accept: ' + result.to_json }
      end
    end
  end

  def reject
    result = @purchase_order.reject('causa')
    respond_to do |format|
      if result[:server][:code] == 200
        format.html { redirect_to purchase_order_url(@purchase_order), notice: 'Purchase order was successfully rejected.' }
      else
        format.html { redirect_to purchase_order_url(@purchase_order), notice: 'Failed to reject: ' + result.to_json }
      end
    end
  end

  def destroy
    @purchase_order.destroy_purchase_order('Cancelada vía botón')
    respond_to do |format|
      format.html { redirect_to purchase_orders_url, notice: 'Purchase order was successfully destroyed.' }
    end
  end

  def create_invoice
    @purchase_order.create_invoice
    respond_to do |format|
      format.html { redirect_to purchase_order_url(@purchase_order), notice: 'Invoice was successfully created.' }
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
