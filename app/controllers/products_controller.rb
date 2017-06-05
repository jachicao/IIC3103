class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :buy_to_factory, :post_buy_to_factory, :confirm_buy_to_factory, :post_confirm_buy_to_factory, :buy_to_producer, :post_buy_to_producer, :confirm_buy_to_producer, :post_confirm_buy_to_producer, :produce, :post_produce, :confirm_produce, :post_confirm_produce]
  before_action :set_ingredients, only: [:confirm_produce, :post_confirm_produce]

  def buy_to_factory

  end

  def post_buy_to_factory
    maximum_time = params[:maximum_time].to_f
    quantity = params[:quantity].to_i
    analysis = @product.get_max_production(quantity)
    respond_to do |format|
      if analysis == nil
        format.html { redirect_to products_path, notice: 'Servidor colapsado' }
      elsif analysis[:time] <= maximum_time
        if analysis[:quantity] == 0
          format.html { redirect_to products_path, notice: 'Supera Stock maximo' }
        else
          format.html { redirect_to controller: 'products', action: 'confirm_buy_to_factory', quantity: analysis[:quantity] }
        end
      else
        format.html { redirect_to buy_to_factory_product_path, notice: 'No se alcanza a cumplir el tiempo'}
      end
    end
  end

  def confirm_buy_to_factory
    @quantity = params[:quantity].to_i
  end


  def post_confirm_buy_to_factory
    quantity = params[:quantity].to_i
    @product.buy_to_factory(quantity)
    respond_to do |format|
      format.html { redirect_to products_path, notice: 'Productos enviados a fabricar' }
    end
  end

  def buy_to_producer
    @product_in_sales = []
    @product.product_in_sales.each do |product_in_sale|
      if product_in_sale.is_mine
      else
        @product_in_sales.push(product_in_sale)
      end
    end
  end

  def post_buy_to_producer
    maximum_time = params[:maximum_time].to_f
    quantity = params[:quantity].to_i
    producer = Producer.find_by(producer_id: params[:producer_id])
    analysis = @product.get_max_purchase_analysis(producer, quantity)

    respond_to do |format|
      if analysis.nil?
        format.html { redirect_to products_path, notice: 'Servidor colapsado' }
      elsif analysis[:time] <= maximum_time
        if analysis[:quantity] == 0
          format.html { redirect_to products_path, notice: 'Supera Stock maximo' }
        else
          format.html { redirect_to controller: 'products', action: 'confirm_buy_to_producer', producer_id: producer.producer_id, quantity: analysis[:quantity], producer_price: analysis[:producer_price], producer_stock: analysis[:producer_stock] }
        end
      else
        format.html { redirect_to buy_to_producer_product_path, notice: 'No se alcanza a cumplir el tiempo' }
      end
    end
  end

  def confirm_buy_to_producer
    @quantity = params[:quantity].to_i
    @producer_price = params[:producer_price].to_i
    @producer_stock = params[:producer_stock].to_i
    @producer = Producer.find_by(producer_id: params[:producer_id])
    @time = 0
    @producer.product_in_sales.each do |product_in_sale|
      if product_in_sale.product.sku == @product.sku
        @time = product_in_sale.average_time
      end
    end
  end

  def post_confirm_buy_to_producer
    quantity = params[:quantity].to_i
    producer_price = params[:producer_price].to_i
    producer = Producer.find_by(producer_id: params[:producer_id])
    @time = 0
    producer.product_in_sales.each do |product_in_sale|
      if product_in_sale.product.sku == @product.sku
        @time = product_in_sale.average_time
      end
    end
    result = @product.buy_to_producer(producer.producer_id, quantity, producer_price, @time)
    respond_to do |format|
      if result == nil
        format.html { redirect_to products_path, notice: 'Servidor colapsado' }
      elsif result[:success]
        format.html { redirect_to products_path, notice: 'Productos enviados a comprar' }
      else
        format.html { redirect_to buy_to_producer_product_path, notice: result.to_json }
      end
    end
  end

  def produce

  end

  def post_produce
    maximum_time = params[:maximum_time].to_f
    quantity = params[:quantity].to_i
    analysis = @product.get_ingredients_analysis(quantity)

    respond_to do |format|
      if analysis.nil?
        format.html { redirect_to products_path, notice: 'Servidor colapsado' }
      elsif analysis[:success]
        if analysis[:time] <= maximum_time
          if analysis[:purchase_ingredients].size == 0
            @product.produce(analysis[:quantity] * @product.lote)
            format.html { redirect_to products_path, notice: 'Producto enviado a producir' }
          else
            format.html { redirect_to controller: 'products', action: 'confirm_produce', quantity: analysis[:quantity], purchase_ingredients: analysis[:purchase_ingredients] }
          end
          format.html { redirect_to produce_product_path, notice: 'No se alcanza a cumplir el tiempo'}
        end
      else
        format.html { redirect_to produce_product_path, notice: 'No se logra producir: ' + analysis.to_json}
      end
    end
  end

  def confirm_produce

  end

  def post_confirm_produce
    @product.purchase_ingredients(@purchase_ingredients)
    @product.produce(@quantity * @product.lote)
    respond_to do |format|
      format.html { redirect_to produce_product_path, notice: 'Ingredientes enviados a comprar y producto a producir' }
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

    def set_ingredients
      @quantity = params[:quantity].to_i
      @purchase_ingredients = []
      if params[:purchase_ingredients] != nil
        params[:purchase_ingredients].each do |item|
          @purchase_ingredients.push({ producer_id: item[:producer_id], quantity: item[:quantity].to_i, time: item[:time].to_f, sku: item[:sku] })
        end
      end
    end
end
