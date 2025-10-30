require 'rails_helper'
RSpec.describe MarkCartAsAbandonedJob, type: :job do
  describe '#perform' do
    describe 'marks carts as abandoned after 3 hours of inactivity' do
      let!(:old_cart) { create(:shopping_cart, abandoned: false, updated_at: 4.hours.ago) }
      let!(:recent_cart) { create(:shopping_cart, abandoned: false, updated_at: 2.hours.ago) }
      it 'marks old carts as abandoned' do
        MarkCartAsAbandonedJob.new.perform
        expect(old_cart.reload.abandoned).to be true
        expect(recent_cart.reload.abandoned).to be false
      end
    end

    describe 'removes carts that have been abandoned for more than 7 days' do
      let!(:abandoned_cart) { create(:shopping_cart, abandoned: true, updated_at: 8.days.ago) }
      let!(:recently_abandoned_cart) { create(:shopping_cart, abandoned: true, updated_at: 6.days.ago) }
      it 'removes abandoned carts older than 7 days' do
        MarkCartAsAbandonedJob.new.perform
        expect { abandoned_cart.reload }.to raise_error(ActiveRecord::RecordNotFound)
        expect(recently_abandoned_cart.reload).to be_present
      end
    end
  end
end
