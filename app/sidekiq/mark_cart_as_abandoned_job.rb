class MarkCartAsAbandonedJob
  include Sidekiq::Job

  def perform(*args)
    Cart.where(abandoned: false).where("updated_at < ?", 3.hours.ago).update_all(abandoned: true, updated_at: Time.current)
    Cart.where(abandoned: true).where("updated_at < ?", 7.days.ago).destroy_all
  end
end
