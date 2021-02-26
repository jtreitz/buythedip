require_relative '../btd.rb'

class NoBTCForMeThx < Strategy
  def description
    "I don't like Bitcoin"
  end

  def execute(usd:, btc:, current_btc_price:, recent_prices:, current_time:)
    [usd, btc]
  end
end

Investor.new.run(NoBTCForMeThx.new)
