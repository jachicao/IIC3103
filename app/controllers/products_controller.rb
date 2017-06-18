class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :buy, :post_buy, :confirm_buy, :post_confirm_buy]

  def buy

  end

  def post_buy
    quantity = params[:quantity].to_i
    group_number = params[:group_number].to_i
    product_in_sale = nil
    @product.product_in_sales.each do |p|
      if p.producer.group_number == group_number
        product_in_sale = p
      end
    end
    puts product_in_sale.producer.group_number
    result = product_in_sale.analyze_buy(quantity)
    respond_to do |format|
      if result[:success]
        format.html { redirect_to controller: 'products', action: 'confirm_buy', analysis: result }
      else
        format.html { redirect_to buy_product_path, notice: 'No es posible de comprar: ' + result.to_json }
      end
    end
  end

  def confirm_buy
    analysis = params[:analysis]
    @purchase_items = []
    self.set_purchase_items(analysis)
  end

  def post_confirm_buy
    purchase_items = params[:purchase_items]
    result = []
    purchase_items.each do |purchase_item|
      product_in_sale = ProductInSale.find_by(id: purchase_item[:id].to_i)
      result.push(product_in_sale.buy_product_sync(purchase_item[:quantity].to_i))
    end
    respond_to do |format|
      format.html { redirect_to products_path, notice: 'Productos enviados a comprar: ' + result.to_json }
    end
  end


  def set_purchase_items(analysis)
    @purchase_items.push({ id: analysis[:id].to_i, quantity: analysis[:quantity].to_i, time: analysis[:time].to_f, success: analysis[:success] })
    if analysis[:purchase_items] != nil
      analysis[:purchase_items].each do |purchase_item|
        self.set_purchase_items(purchase_item)
      end
    end
  end

  # GET /products
  # GET /products.json
  def index
    @products = Product.all
    @me = Producer.get_me
    @my_products = []
    @my_ingredients = []
    @me.product_in_sales.each do |product_in_sale|
      @my_products[product_in_sale.product.sku.to_i] = product_in_sale.product
      product_in_sale.product.ingredients.each do |ingredient|
        @my_ingredients[ingredient.item.sku.to_i] = ingredient.item
      end
    end
  end

  # GET /products/1
  # GET /products/1.json
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit(:sku, :name, :product_type, :unit, :unit_cost, :lote)
    end
end
