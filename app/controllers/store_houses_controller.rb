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
    respond_to do |format|
      format.html { render :move_internally }
      format.json { render :json => { :error => 'Only html' } }
    end
  end

  def submit_move_internally
    from_store_houses = StoreHouse.get_store_house(_id: params[:from_store_house_id])
    to_store_houses = StoreHouse.get_store_house(_id: params[:to_store_house_id])
    result = StoreHouse.move_stock(from_store_houses, to_store_houses, params[:sku], params[:quantity].to_i)
    respond_to do |format|
      if result == 0
        format.html { redirect_to store_houses_path, notice: 'Productos movidos exitosamente' }
        format.json { render json: { :message => 'Productos movidos exitosamente' } }
      else
        format.html { redirect_to store_houses_path, notice: 'Faltaron ' + result.to_s + ' productos por mover' }
        format.json { render json: { error: 'Faltaron ' + result.to_s + ' productos por mover' }, status: :unprocessable_entity }
      end
    end
  end

  def move_externally

  end

  def submit_move_externally

  end

  def clean_pulmon
    result = StoreHouse.clean_pulmon
    respond_to do |format|
      if result == 0
        format.html { redirect_to store_houses_path, notice: 'Almacen limpiado exitosamente' }
        format.json { render json: { :message => 'Almacen limpiado exitosamente' } }
      else
        format.html { redirect_to store_houses_path, notice: 'Faltaron ' + result.to_s + ' productos por mover' }
        format.json { render json: { error: 'Faltaron ' + result.to_s + ' productos por mover' } }
      end
    end
  end

  def clean_recepcion
    result = StoreHouse.clean_recepcion
    respond_to do |format|
      if result == 0
        format.html { redirect_to store_houses_path, notice: 'Almacen limpiado exitosamente' }
        format.json { render json: { :message => 'Almacen limpiado exitosamente' } }
      else
        format.html { redirect_to store_houses_path, notice: 'Faltaron ' + result.to_s + ' productos por mover' }
        format.json { render json: { error: 'Faltaron ' + result.to_s + ' productos por mover' } }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_store_house
      @store_house = StoreHouse.get_store_house(params[:id])
      @stock = StoreHouse.get_stock(params[:id])
    end

end
