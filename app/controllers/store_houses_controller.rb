class StoreHousesController < ApplicationController
  before_action :set_store_house, only: [:show, :update, :destroy]

  # GET /store_houses
  def index
    @store_houses = StoreHouse.all

    render json: @store_houses
  end

  # GET /store_houses/1
  def show
    render json: @store_house
  end

  # POST /store_houses
  def create
    @store_house = StoreHouse.new(store_house_params)

    if @store_house.save
      render json: @store_house, status: :created, location: @store_house
    else
      render json: @store_house.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /store_houses/1
  def update
    if @store_house.update(store_house_params)
      render json: @store_house
    else
      render json: @store_house.errors, status: :unprocessable_entity
    end
  end

  # DELETE /store_houses/1
  def destroy
    @store_house.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_store_house
      @store_house = StoreHouse.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def store_house_params
      params.require(:store_house).permit(:usedSpace, :totalSpace, :reception, :dispatch, :external)
    end
end
