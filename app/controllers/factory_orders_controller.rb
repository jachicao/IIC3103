class FactoryOrdersController < ApplicationController

  # GET /factory_orders
  # GET /factory_orders.json
  def index
    @factory_orders = FactoryOrder.all
  end

end
