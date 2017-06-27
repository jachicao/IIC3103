class PurchaseOrdersController < ApplicationController
  before_action :set_purchase_order, only: [:show, :destroy]

  # GET /purchase_orders
  # GET /purchase_orders.json
  def index
    @b2b_purchase_orders = PurchaseOrder.all.select { |v| v.is_b2b && !(v.is_rejected || v.is_cancelled) }
    @b2c_purchase_orders = PurchaseOrder.all.select { |v| v.is_b2c }
    @ftp_purchase_orders = PurchaseOrder.all.select { |v| v.is_ftp }
  end

  # GET /purchase_orders/1
  # GET /purchase_orders/1.json
  def show
  end

  def destroy
    @purchase_order.cancel('Cancelada vía botón')
    respond_to do |format|
      format.html { redirect_to purchase_orders_url, notice: 'Purchase order was successfully destroyed.' }
    end
  end

  def api_create
    if params[:po_id].nil?
      return render :json => { :success => false, :error => 'Falta po_id' }, status: :bad_request
    end
    if params[:id_store_reception].nil?
      return render :json => { :success => false, :error => 'Falta id_store_reception' }, status: :bad_request
    end
    if params[:payment_method].nil?
      return render :json => { :success => false, :error => 'Falta payment_method' }, status: :bad_request
    else
      if ['contra_despacho', 'contra_factura'].include?(params[:payment_method])
      else
        return render :json => { :success => false, :error => 'payment_method debe ser contra_despacho o contra_factura' }, status: :bad_request
      end
    end

    @purchase_order = PurchaseOrder.create_new(params[:po_id])
    if @purchase_order != nil
      @purchase_order.update(
          store_reception_id: params[:id_store_reception],
          payment_method: params[:payment_method])
      return render :json => { :success => true }
    else
      return render :json => { :success => false, :error => 'PurchaseOrder not found' }, status: :not_found
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
