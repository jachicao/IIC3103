class PendingProductsController < ApplicationController
  before_action :set_pending_product, only: [:show, :destroy]

  def index
    @pending_products = PendingProduct.all
  end

  def show

  end

  def destroy
    @pending_product.destroy
    respond_to do |format|
      format.html { redirect_to pending_products_path, notice: 'Pending product was successfully destroyed.' }
    end
  end

  private
    def set_pending_product
      @pending_product = PendingProduct.find(params[:id])
    end
end
