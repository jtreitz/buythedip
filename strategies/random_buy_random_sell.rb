require_relative '../btd.rb'

class RandomBuyRandomSell < Strategy
  attr_accessor :price_paid, :buy_percent, :sell_percent

  def description
    "Buy whenever, sell whenever"
  end

  def execute(usd:, btc:, current_btc_price:, recent_prices:, current_time:)
    if usd && [true, false].sample
      btc = btc + usd.fdiv(current_btc_price)
      usd = 0
    end
    if btc && [true, false].sample
      usd = usd + btc * current_btc_price
      btc = 0
    end
    [usd, btc]
  end
end

Investor.new.run(RandomBuyRandomSell.new)