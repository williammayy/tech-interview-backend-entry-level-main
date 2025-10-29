class Cart < ApplicationRecord
  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  def last_interaction_at
    updated_at
  end

  def last_interaction_at=(value)
    self.updated_at = value
  end

  def mark_as_active
    update(abandoned: false)
  end

  def mark_as_abandoned
    update(abandoned: true)
  end

  def remove_if_abandoned
    destroy if abandoned?
  end
end
