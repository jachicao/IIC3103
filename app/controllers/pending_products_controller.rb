class PendingProductsController < ApplicationController
  before_action :set_pending_product, only: [:show]

  def index
    @pending_products = PendingProduct.all
  end

  def show

  end

  private
    def set_pending_product
      @pending_product = PendingProduct.find(params[:id])
    end
end
