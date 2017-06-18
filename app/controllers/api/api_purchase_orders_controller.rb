class Api::ApiPurchaseOrdersController < Api::ApiController
  before_action :set_purchase_order, only: [:accepted, :rejected]

  # POST /purchase_orders
  # POST /purchase_orders.json
  def create
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

    set_purchase_order

    if @purchase_order != nil
      return render :json => { :success => true }
    end

    response = PurchaseOrder.get_server_details(params[:po_id])
    case response[:code]
      when 200
        body = response[:body]
        params[:store_reception_id] = params[:id_store_reception]
        @purchase_order = PurchaseOrder.new({
                                                po_id: body[:_id],
                                                store_reception_id: params[:store_reception_id],
                                                payment_method: params[:payment_method],
                                            })
        if @purchase_order.save
          @purchase_order.update_properties_sync
          return render :json => { :success => true }
        else
          return render :json => { :success => false, :error => @purchase_order.errors } , status: :unprocessable_entity
        end
    end
    return render :json => { :success => false, :error => response[:body] }, status: response[:code]
  end

  # PATCH/PUT /purchase_orders/1/accepted
  # PATCH/PUT /purchase_orders/1/accepted.json
  def accepted
    if @purchase_order != nil
      @purchase_order.update_properties_async
      return render :json => { :success => true }
    else
      return render :json => { :success => false, :error => 'PurchaseOrder not found' }, status: :not_found
    end
  end

  # PATCH/PUT /purchase_orders/1/rejected
  # PATCH/PUT /purchase_orders/1/rejected.json
  def rejected
    if @purchase_order != nil
      @purchase_order.update_properties_async
      return render :json => { :success => true }
    else
      return render :json => { :success => false, :error => 'PurchaseOrder not found' }, status: :not_found
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_purchase_order
      @purchase_order = PurchaseOrder.find_by(po_id: params[:po_id])
    end
end
