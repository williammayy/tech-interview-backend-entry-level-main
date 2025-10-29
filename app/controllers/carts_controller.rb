class CartsController < ApplicationController
  before_action :set_cart
  before_action :ensure_quantity_is_positive, only: [:add_item]
  before_action :ensure_product_exists, only: [:add_item]

  def add_item
    cart_item = @cart.cart_items.find_by(product_id: params[:product_id])
    if cart_item
      cart_item.quantity += params[:quantity].to_i
      cart_item.save
    else
      @cart.cart_items.create(product_id: params[:product_id], quantity: params[:quantity])
    end
    update_total_price
    render json: { message: 'Item added to cart successfully', cart: get_cart_details }, status: :ok
  end

  private

  def get_cart_details
    {
      id: @cart.id,
      total_price: @cart.total_price.to_f,
      products: @cart.products.map do |product|
        {
          id: product.id,
          name: product.name,
          quantity: (@cart.cart_items.find_by(product_id: product.id).quantity).to_f,
          unit_price: product.price.to_f,
          total_price: (@cart.cart_items.find_by(product_id: product.id).quantity * product.price).to_f
        }
      end
    }
  end

  def update_total_price
    total_price = @cart.cart_items.sum { |item| item.product.price * item.quantity }
    @cart.update(total_price: total_price)
  end

  def set_cart
    @cart = Cart.find_by(id: session[:cart_id])
    if @cart.nil?
      @cart = Cart.create(total_price: 0)
      session[:cart_id] = @cart.id
    end
  end

  def ensure_quantity_is_positive
    if params[:quantity].to_i < 1
      @cart.errors.add(:quantity, 'Must be greater than or equal to 1')
      return render json: { errors: @cart.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def ensure_product_exists
    if params[:product_id].blank? || Product.find_by(id: params[:product_id]).nil?
      @cart.errors.add(:product, 'Must exist')
      return render json: { errors: @cart.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
