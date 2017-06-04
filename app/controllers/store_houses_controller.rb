class StoreHousesController < ApplicationController
  before_action :set_store_house, only: [:show]

  def index
    @store_houses = StoreHouse.all
    respond_to do |format|
      format.html { render :index }
      format.json { render :json => @store_houses }
    end
  end

  def show
    respond_to do |format|
      format.html { render :show }
      format.json { render :json => @store_house }
    end
  end

  def move_internally
    @store_houses = StoreHouse.all
  end

  def submit_move_internally
    from_store_houses = StoreHouse.all.select { |v| v[:_id] == params[:from_store_house_id] }
    to_store_houses = StoreHouse.all.select { |v| v[:_id] == params[:to_store_house_id] }
    quantity = params[:quantity].to_i
    sku = params[:sku]
    result = StoreHouse.can_move_stock(from_store_houses, to_store_houses, sku, quantity)
    respond_to do |format|
      if result == nil
        format.html { redirect_to store_houses_path, notice: 'Servidor colapsado' }
      elsif result == true
        StoreHouse.move_stock(from_store_houses, to_store_houses, sku, quantity)
        format.html { redirect_to store_houses_path, notice: 'Productos movidos exitosamente' }
      else
        format.html { redirect_to store_houses_path, notice: 'Cantidad excede stock' }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_store_house
      @store_house = StoreHouse.get_store_house(params[:id])
      @stock = []
      if @store_house != nil and @store_house[:usedSpace] > 0
        @stock = StoreHouse.get_stock(params[:id])
      end
    end

end
