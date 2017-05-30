class ProducersController < ApplicationController
  # GET /producers
  # GET /producers.json
  def index
    @producers = Producer.all
  end
end
