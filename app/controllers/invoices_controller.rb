class InvoicesController < ApplicationController
  before_action :set_invoice, only: [:show, :paid, :failed]

  def index
    @invoices = Invoice.all
  end

  def show
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