class PromotionsController < ApplicationController
  before_action :set_promotion, only: [:destroy]

  def index
    @promotions = Promotion.all
  end

  def destroy
    @promotion.destroy
    return redirect_to promotions_path
  end

  private
    def set_promotion
      @promotion = Promotion.find(params[:id])
    end
end