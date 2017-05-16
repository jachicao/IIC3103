require 'test_helper'

class ProductInSalesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @product_in_sale = product_in_sales(:one)
  end

  test "should get index" do
    get product_in_sales_url
    assert_response :success
  end

  test "should get new" do
    get new_product_in_sale_url
    assert_response :success
  end

  test "should create product_in_sale" do
    assert_difference('ProductInSale.count') do
      post product_in_sales_url, params: { product_in_sale: { average_time: @product_in_sale.average_time, price: @product_in_sale.price, producer_id: @product_in_sale.producer_id, product_id: @product_in_sale.product_id } }
    end

    assert_redirected_to product_in_sale_url(ProductInSale.last)
  end

  test "should show product_in_sale" do
    get product_in_sale_url(@product_in_sale)
    assert_response :success
  end

  test "should get edit" do
    get edit_product_in_sale_url(@product_in_sale)
    assert_response :success
  end

  test "should update product_in_sale" do
    patch product_in_sale_url(@product_in_sale), params: { product_in_sale: { average_time: @product_in_sale.average_time, price: @product_in_sale.price, producer_id: @product_in_sale.producer_id, product_id: @product_in_sale.product_id } }
    assert_redirected_to product_in_sale_url(@product_in_sale)
  end

  test "should destroy product_in_sale" do
    assert_difference('ProductInSale.count', -1) do
      delete product_in_sale_url(@product_in_sale)
    end

    assert_redirected_to product_in_sales_url
  end
end
