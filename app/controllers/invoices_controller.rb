class InvoicesController < ApplicationController
  before_action :set_invoice, only: [:show, :pay, :paid, :failed]

  def index
    @invoices = Invoice.all
  end

  def show
  end

  def api_create
    if params[:bank_account].nil?
      return render :json => { :success => false, :error => 'Falta bank_account' }, status: :bad_request
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

  def pay
    @invoice.pay
    respond_to do |format|
      format.html { render :show }
    end
  end

  def paid
    @invoice.bill_paid
    respond_to do |format|
      format.html { redirect_to spree_path, notice: 'Transacción exitosa' }
    end
  end

  def failed
    @invoice.bill_failed
    respond_to do |format|
      format.html { redirect_to spree_path, notice: 'Falló la transacción' }
    end
  end

  private
    def set_invoice
      @invoice = Invoice.find(params[:id])
    end
end