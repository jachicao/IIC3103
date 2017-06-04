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
      if params[:payment_method] == 'contra_despacho'
      elsif params[:payment_method] == 'contra_factura'
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
        body = response[:body].first
        params[:store_reception_id] = params[:id_store_reception]
        @purchase_order = PurchaseOrder.new({ po_id: body[:_id],
                                              store_reception_id: params[:store_reception_id],
                                              payment_method: params[:payment_method],
                                              client_id: body[:cliente],
                                              supplier_id: body[:proveedor],
                                              delivery_date: DateTime.parse(body[:fechaEntrega]),
                                              unit_price: body[:precioUnitario],
                                              sku: body[:sku],
                                              quantity: body[:cantidad],
                                              own: false,
                                              dispatched: false })
        if @purchase_order.save
          AnalyzePurchaseOrderWorker.perform_async(body[:_id])
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
      return render :json => { :success => true }
=begin
      response = PurchaseOrder.get_server_details(params[:po_id])
      case response[:code]
        when 200
          body = response[:body].first
          case body[:estado]
            when 'creada'
              return render :json => { :success => true }
          end
          return render :json => { :success => false, :error => 'Estado de orden de compra no es \'creada\'' }, status: :bad_request
      end
      return render :json => { :success => false, :error => response[:body] }, status: response[:code]
=end
    else
      return render :json => { :success => false, :error => 'PurchaseOrder not found' }, status: :not_found
    end
  end

  # PATCH/PUT /purchase_orders/1/rejected
  # PATCH/PUT /purchase_orders/1/rejected.json
  def rejected
=begin
    if params[:cause].nil?
      return render :json => { :success => false, :error => 'Falta cause' }, status: :bad_request
    end
=end
    if @purchase_order != nil
      return render :json => { :success => true }
=begin
      response = PurchaseOrder.get_server_details(params[:po_id])
      case response[:code]
        when 200
          body = response[:body].first
          case body[:estado]
            when 'creada'
              return render :json => { :success => true }
          end
          return render :json => { :success => false, :error => 'Estado de orden de compra no es \'creada\'' }, status: :bad_request
      end
      return render :json => { :success => false, :error => response[:body] }, status: response[:code]
=end
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
