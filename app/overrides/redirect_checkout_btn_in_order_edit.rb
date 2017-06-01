Deface::Override.new(
                    virtual_path: 'spree/orders/edit',
                    name: 'redirect_checkout_btn_in_order_edit',
                    replace: "erb[loud]:contains('checkout-link')",
                    text: "<%= link_to '/create_bill_web/'+ @order.id.to_s, class: 'btn btn-success' do %>")