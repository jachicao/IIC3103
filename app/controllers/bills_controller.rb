class BillsController < ApplicationController
  before_action :set_bill, only: [:show, :update, :destroy]

  # GET /bills
  def index
    @bills = Bill.all

    render json: @bills
  end

  # GET /bills/1
  def show
    render json: @bill
  end

  # PUT /bills
  def create
    #@bill = Bill.new(bill_params)
    #if @bill.save
    if params[:token].present?
      render json: '{"supplier": "grupo 1","client": "grupo 2","grossValue": 3000,"Iva": 300,"totalValue": 3300,"Deadline": "17 / 10 / 2017","orderId": "qsda1","RejectionCause": "","CancellationCause": ""}', status: 202
    else
      render json: {"error": "Token needed" }, status: 403
    end
  end

  #PUT /bills/1/acepted
  def acepted
    if params[:token].present?
      render json: '{"supplier": "grupo 1","client": "grupo 2","grossValue": 3000,"Iva": 300,"totalValue": 3300,"paymentStatus": "pendiente","Deadline": "17 / 10 / 2017","orderId": "qsda1","RejectionCause": "","CancellationCause": ""}', status: 202
    else
      render json: {"error": "Token needed" }, status: 403
    end
  end

  #PUT /bills/1/rejected
  def rejected
    if params[:token].present?
      render json: '{"supplier": "grupo 1","client": "grupo 2","grossValue": 3000,"Iva": 300,"totalValue": 3300,"paymentStatus": "rechazado","Deadline": "17 / 10 / 2017","orderId": "qsda1","RejectionCause": "","CancellationCause": ""}', status: 202
    else
      render json: {"error": "Token needed" }, status: 403
    end
  end

  #PUT /bills/1/paid
  def paid
    if params[:token].present?
      render json: '{"supplier": "grupo 1","client": "grupo 2","grossValue": 3000,"Iva": 300,"totalValue": 3300,"paymentStatus": "paid","Deadline": "17 / 10 / 2017","orderId": "qsda1","RejectionCause": "","CancellationCause": ""}', status: 202
    else
      render json: {"error": "Token needed" }, status: 403
    end
  end


  # PATCH/PUT /bills/1
  def update
    if @bill.update(bill_params)
      render json: @bill
    else
      render json: @bill.errors, status: :unprocessable_entity
    end
  end

  # DELETE /bills/1
  def destroy
    @bill.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bill
      @bill = Bill.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def bill_params
      params.require(:bill).permit(:supplier, :client, :grossValue, :iva, :totalValue, :paymentStatus, :pushaseOrderId, :paymentDeadline, :rejectionCause, :CancellationCause)
    end
end
