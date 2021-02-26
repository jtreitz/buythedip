require_relative '../btd.rb'

class HODLAndBuyMore < Strategy
  def execute(usd:, btc:, current_btc_price:, recent_prices:, current_time:)
    # Never sell, but always buy
    if usd > 0
      new_btc = btc + usd.fdiv(current_btc_price)
      new_usd = 0
      [new_usd, new_btc]
    else
      [usd, btc]
    end
  end
end

Investor.new.run(HODLAndBuyMore.new)
