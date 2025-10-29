require 'rails_helper'

RSpec.describe "/carts", type: :request do
  describe "POST cart/add_item or POST cart" do
    let(:product) { create(:product, price: 15.0) }
    let(:product_two) { create(:product) }

    context 'success' do
      context 'when adding a new product to the cart' do
        subject { post '/cart/add_item', params: { product_id: product.id, quantity: 1 }, as: :json }

        it 'creates a new cart item' do
          subject
          expect(response).to have_http_status(:ok)
          expect(CartItem.last.quantity).to eq(1)
          response_cart = JSON.parse(response.body)["cart"]
          expect(response_cart).to eq(cart_expectations(Cart.last, [{ product: product, quantity: 1 }]))
        end
      end

      context 'when the product already is in the cart' do
        before { post '/cart/add_item', params: { product_id: product_two.id, quantity: 1 }, as: :json }
        subject { post '/cart/add_item', params: { product_id: product_two.id, quantity: 1 }, as: :json }

        it 'updates the quantity of the existing item in the cart' do
          subject
          expect(response).to have_http_status(:ok)
          expect(CartItem.last.quantity).to eq(2)
          response_cart = JSON.parse(response.body)["cart"]
          expect(response_cart).to eq(cart_expectations(Cart.last, [{ product: product_two, quantity: 2 }]))
        end
      end
    end

    context 'errors' do
      context 'when no product_id is provided' do
        subject { post '/cart', params: { product_id: nil, quantity: 1 }, as: :json }

        it 'returns an error' do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)["errors"]).to include('Product Must exist')
        end
      end

      context 'when product does not exist' do
        subject { post '/cart', params: { product_id: -1, quantity: 1 }, as: :json }

        it 'returns an error' do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)["errors"]).to include('Product Must exist')
        end
      end

      context 'when quantity is less than 1' do
        subject { post '/cart/add_item', params: { product_id: product.id, quantity: 0 }, as: :json }

        it 'returns an error' do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)["errors"]).to include('Quantity Must be greater than or equal to 1')
        end
      end
    end
  end

  private

  def cart_expectations(cart, items)
    {
      "id" => cart.id,
      "total_price" => items.sum { |item| (item[:product].price * item[:quantity]).to_f },
      "products" => items.map do |item|
        {
          "id" => item[:product].id,
          "name" => item[:product].name,
          "quantity" => item[:quantity],
          "unit_price" => item[:product].price.to_f,
          "total_price" => (item[:product].price * item[:quantity]).to_f
        }
      end
    }
  end
end
