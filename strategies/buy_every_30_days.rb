require_relative '../btd.rb'

# Buy every 30 days strict
class BuyEvery30Days < Strategy
  attr_reader :last_purchase_time

  def initialize
    @last_purchase_time = Time.at(0)
  end

  def execute(usd:, btc:, current_btc_price:, recent_prices:, current_time:)
    next_purchase_time = last_purchase_time + (30 * 24 * 60 * 60)

    # After 30 days, spend it all
    if current_time >= next_purchase_time && usd > 0
      new_btc = btc + usd.fdiv(current_btc_price)
      new_usd = 0
      @last_purchase_time = current_time
      [new_usd, new_btc]
    else
      [usd, btc]
    end
  end
end

Investor.new.run(BuyEvery30Days.new)
