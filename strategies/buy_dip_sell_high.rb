require_relative '../btd.rb'

class BuyDipSellHigh < Strategy
  attr_accessor :price_paid, :buy_percent, :sell_percent

  def initialize(buy_percent: 0.9, sell_percent: 1.1)
    self.price_paid = 0
    self.buy_percent = buy_percent
    self.sell_percent = sell_percent
  end

  def description
    "Purchase when price went down #{((sell_percent - 1) * 100).round(2)}%, " +
    "sell when price goes up #{((1 - buy_percent) * 100).round(2)}%"
  end

  def execute(usd:, btc:, current_btc_price:, recent_prices:, current_time:)
    if usd > 0 && current_btc_price < (recent_prices.max * self.buy_percent)
      self.price_paid = current_btc_price

      btc = btc + usd.fdiv(current_btc_price)
      usd = 0

      [usd, btc]
    elsif btc > 0 && current_btc_price > (self.price_paid * self.sell_percent)
      usd = usd + btc * current_btc_price
      btc = 0

      [usd, btc]
    else
      [usd, btc]
    end
  end
end

investor = Investor.new
investor.run(BuyDipSellHigh.new)
investor.run(BuyDipSellHigh.new(buy_percent: 0.8, sell_percent: 1.2))
investor.run(BuyDipSellHigh.new(buy_percent: 0.95, sell_percent: 1.05))
