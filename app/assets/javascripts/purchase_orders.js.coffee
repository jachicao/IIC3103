$(document).ready ->
  $(".cliente_selection").on "change", ->
    $.ajax
      url: "/purchase_orders/get_products"
      type: "GET"
      dataType: "script"
      data:
        producer_id: $('.cliente_selection option:selected').val()
