class Cart < ApplicationRecord
  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  # TODO: lógica para marcar o carrinho como abandonado e remover se abandonado
end
