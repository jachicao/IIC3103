class FactoryController < ApplicationController

  def index
    @factory_orders = FactoryOrder.all
    respond_to do |format|
      format.html { render :index }
      format.json { render :json => @factory_orders }
    end
  end

  def get_lote(lote, cantidad)
    return (cantidad.to_f / lote.to_f).ceil
  end

  def stock_available(stock, item)
    counter = 0
    stock.each do |almacen|
      almacen[:inventario].each do |inventario|
        if item.sku == inventario[:sku]
          counter += inventario[:total]
        end
      end
    end
    return counter
  end

  def get_stock()
    result = []
    almacenes = StoreHouse.all_stock
    if almacenes == nil
      return nil
    end

    almacenes.each do |almacen|
      if !almacen[:despacho]
        result.push(almacen)
      end
    end
    return result
  end

  def analizar_stock(producto, cantidad)
    stock = get_stock()
    lote = get_lote(producto.lote, cantidad)
    tiempo_maximo = 0.0
    vendedores = []
    stock_disponible_producto = stock_available(stock, producto);
    if stock_disponible_producto >= cantidad
      return { :tiempo_maximo => tiempo_maximo, :vendedores => vendedores }
    end
    producto.ingredients.each do |ingredient|
      stock_disponible = stock_available(stock, ingredient.item)
      difference = ingredient.quantity * lote - stock_disponible
      if difference > 0
        orderedList = ingredient.item.product_in_sales.order('average_time ASC')
        orderedList.each do |product_in_sale|
          tiempo_maximo = [tiempo_maximo, product_in_sale.average_time].max
          vendedores.push({ vendedor_id: product_in_sale.producer.producer_id, sku: ingredient.item.sku, cantidad: difference });
          break;
        end
        #return { :error => "Cantidad no suficiente" }
      end
    end
    return { :tiempo_maximo => tiempo_maximo, :vendedores => vendedores }
  end

  def submit_producir
    nombre = params[:producto].to_s
    cantidad = params[:cantidad].to_i
    tiempo = params[:tiempo].to_f
    producto = Product.all.find_by(name: nombre)
    analisis = analizar_stock(producto, cantidad)
    if analisis[:tiempo_maximo] <= tiempo
      redirect_to action: "detalles", nombre: nombre, cantidad: cantidad, tiempo: tiempo
    else
      render json: { :error => "No se alcanza a producir" }
    end
    MakeProductsWithoutPaymentJob.perform_later(producto.sku, params[:cantidad].to_i)
  end

  def producir_real #en la 2da ventana
    #guardar parametro nombre
    #guardar parametro productor-sku
    #guardar cantidad
    #mandar oc y/o producir
    #esperar oc y mover ingredientes a despacho
    #MakeProductsWithoutPaymentJob.perform_later(producto.sku, params[:cantidad].to_i)
  end

  def new
    @products = []
    ProductInSale.all.each do |product_in_sale|
      if product_in_sale.mine
        @products.push(product_in_sale.product)
      end
    end
  end

  def detalles
    render json: {:success => true}
  end
end
