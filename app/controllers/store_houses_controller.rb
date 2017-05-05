class StoreHousesController < ApplicationController
  before_action :set_store_house, only: [:show, :edit, :update, :destroy]

  # GET /store_houses
  # GET /store_houses.json
  def index
    @store_houses = StoreHouse.all
  end

  # GET /store_houses/1
  # GET /store_houses/1.json
  def show
  end

  # GET /store_houses/new
  def new
    @store_house = StoreHouse.new
  end

  # GET /store_houses/1/edit
  def edit
  end

  # POST /store_houses
  # POST /store_houses.json
  def create
    @store_house = StoreHouse.new(store_house_params)

    respond_to do |format|
      if @store_house.save
        format.html { redirect_to @store_house, notice: 'Store house was successfully created.' }
        format.json { render :show, status: :created, location: @store_house }
      else
        format.html { render :new }
        format.json { render json: @store_house.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /store_houses/1
  # PATCH/PUT /store_houses/1.json
  def update
    respond_to do |format|
      if @store_house.update(store_house_params)
        format.html { redirect_to @store_house, notice: 'Store house was successfully updated.' }
        format.json { render :show, status: :ok, location: @store_house }
      else
        format.html { render :edit }
        format.json { render json: @store_house.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /store_houses/1
  # DELETE /store_houses/1.json
  def destroy
    @store_house.destroy
    respond_to do |format|
      format.html { redirect_to store_houses_url, notice: 'Store house was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_store_house
      @store_house = StoreHouse.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def store_house_params
      params.require(:store_house).permit(:usedSpace, :totalSpace, :reception, :dispatch, :external)
    end
end
