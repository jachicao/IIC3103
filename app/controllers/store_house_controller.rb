class StoreHouseController < ApplicationController

  def index
    store_house = StoreHouse.new
    render json: store_house.getStock();
  end
  
end
