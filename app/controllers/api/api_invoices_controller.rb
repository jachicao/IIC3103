class Api::ApiInvoicesController < Api::ApiController
  before_action :set_invoice, only: [:accepted, :rejected, :paid, :delivered]

  def create
    if params[:bank_account].nil?
      return render :json => { :success => false, :error => 'Falta bank_account' }, status: :bad_request
    end

    set_invoice

    if @invoice != nil
      return render json: { :success => true }
    end

    @invoice = Invoice.create_new(params[:invoice_id])
    if @invoice != nil
      @invoice.update(
          bank_id: params[:bank_account],
      )
    else
      return render :json => { :success => false, :error => 'Invoice not found' }, status: :not_found
    end
  end

  def accepted
    if @invoice != nil
      @invoice.update_properties_async
      return render :json => { :success => true }
    else
      return render :json => { :success => false, :error => 'Invoice not found' }, status: :not_found
    end
  end

  def rejected
    if @invoice != nil
      @invoice.update_properties_async
      return render :json => { :success => true }
    else
      return render :json => { :success => false, :error => 'Invoice not found' }, status: :not_found
    end
  end

  def paid
    if params[:id_transaction].nil?
      return render :json => { :success => false, :error => 'Falta id_transaction' }, status: :bad_request
    end

    if @invoice != nil
      @invoice.update(trx_id: params[:id_transaction])
      @invoice.update_properties_async
      return render :json => { :success => true }
    else
      return render :json => { :success => false, :error => 'Invoice not found' }, status: :not_found
    end
  end

  def delivered
    if @invoice != nil
      @invoice.update_properties_async
      return render :json => { :success => true }
    else
      return render :json => { :success => false, :error => 'Invoice not found' }, status: :not_found
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_invoice
      @invoice = Invoice.find_by(_id: params[:invoice_id])
    end
end
