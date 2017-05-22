class Api::ApiPurchaseOrdersController < Api::ApiController
  before_action :set_purchase_order, only: [:update_accepted, :update_rejected]

  # POST /purchase_orders
  # POST /purchase_orders.json
  def create
    if params[:po_id].nil?
      return render :json => { :success => false, :error => 'Falta po_id' }, status: :bad_request
    end
    if params[:id_store_reception].nil?
      return render :json => { :success => false, :error => 'Falta store_reception_id' }, status: :bad_request
    end
    if params[:payment_method].nil?
      return render :json => { :success => false, :error => 'Falta payment_method' }, status: :bad_request
    end

    response = GetPurchaseOrderJob.perform_now(params[:po_id])
    case response[:code]
      when 200
        params[:store_reception_id] = params[:id_store_reception]
        @purchase_order = PurchaseOrder.new({ po_id: params[:po_id], store_reception_id: params[:store_reception_id], payment_method: params[:payment_method], status: 'created' })
        if @purchase_order.save
          return render json: { :success => true }
        else
          return render json: { :success => false, :error => @purchase_order.errors } , status: :unprocessable_entity
        end
    end
    return render :json => { :success => false, :error => response[:body] }, status: response[:code]
  end

  # PATCH/PUT /purchase_orders/1/accepted
  # PATCH/PUT /purchase_orders/1/accepted.json
  def update_accepted
    if @purchase_order != nil
      if @purchase_order.update(status: 'accepted')
        return render json: { :success => true }
      else
        return render json: { :success => false, :error => @purchase_order.errors } , status: :unprocessable_entity
      end
    else
      render :json => { :success => false,  :error => 'PurchaseOrder not found' }, status: :not_found
    end
  end

  # PATCH/PUT /purchase_orders/1/rejected
  # PATCH/PUT /purchase_orders/1/rejected.json
  def update_rejected
    if @purchase_order != nil
      if @purchase_order.update(status: 'rejected')
        return render json: { :success => true }
      else
        return render json: { :success => false, :error => @purchase_order.errors } , status: :unprocessable_entity
      end
    else
      render :json => { :success => false,  :error => 'PurchaseOrder not found' }, status: :not_found
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_purchase_order
      @purchase_order = PurchaseOrder.find_by(po_id: params[:po_id])
    end
end
