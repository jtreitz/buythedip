#!/usr/bin/env ruby

require 'csv'
require 'time'
require 'date'
require './time_series.rb'

unless defined? DEBUG_OUTPUT
  DEBUG_OUTPUT = (ARGV.join =~ /\-\-debug/) # '--debug' enables debug output
  START_TIME = Time.parse('2020-01-01')
end

# Inherit your custom strategy from this, #execute will be called for every
# entry in the BTC timeseries
class Strategy
  def description
    self.class.name
  end

  # Must return new balances for USD and BTC as array
  def execute(usd:, btc:, current_btc_price:, recent_prices:, current_time:)
    raise NotImplementedError
  end
end

# Main class running the strategies
class Investor
  attr_reader :savings_rate, :initial_usd, :initial_btc

  def initialize(savings_rate: 100, initial_usd: 0, initial_btc: 0)
    @savings_rate = savings_rate
    @initial_usd = initial_usd
    @initial_btc = initial_btc

    puts
    puts "There's a new investor in town! They start with $#{initial_usd} and ฿#{initial_btc}, " +
         "adding $#{savings_rate} to their budget every 1st of the month."
    puts
  end

  def execute_on_timeseries(&block)
    db = TimeSeries.new
    most_recent_price = nil

    CSV.foreach('btcusd.csv', headers: true, header_converters: :symbol) do |row|
      time = Time.parse(row[:date])
      next if time < START_TIME # ignore data before 2020

      most_recent_price = row[:high].to_i
      db << TimeSeries::DataPoint.new(time, most_recent_price)
      db = db.slice(time - 24*60*60, time) # truncate
      recent = db.map(&:data)

      block.call(most_recent_price, recent, time)
    end

    most_recent_price
  end

  def run(strategy)
    raise "Your strategy must inherit from the Strategy class" unless strategy.kind_of? Strategy

    # Starting variables
    usd = @initial_usd
    btc = @initial_btc
    last_price = 0
    savings_rate = @savings_rate
    next_savings_rate_at = Time.at(0)

    puts
    puts "Strategy: \e[1m\e[4m#{strategy.description}\033[0m"

    # For every entry in the time series
    execute_on_timeseries do |current_btc_price, recent_prices, current_time|
      # For debug output, format time
      formatted_time = current_time.strftime("%m/%d/%Y %H:%M")

      # See if we can add more money
      if next_savings_rate_at < current_time
        if DEBUG_OUTPUT
          puts "#{formatted_time} ADD $#{savings_rate.round(2)} TO USD BUDGET"
        end

        usd += savings_rate
        next_savings_rate_at = (current_time.to_date >> 1).to_time
      end

      # Run strategy and allow it to purchase/sell
      options = {
        usd: usd,
        btc: btc,
        current_btc_price: current_btc_price,
        recent_prices: recent_prices,
        current_time: current_time
      }

      # Write down the new balances of USD and BTC after the strategy ran, then continue
      new_usd, new_btc = strategy.execute(**options)

      if DEBUG_OUTPUT
        btc_difference = new_btc - btc
        usd_difference = new_usd - usd

        if btc_difference > 0
          puts "#{formatted_time} BUY $#{usd_difference.abs.round(2)} = ฿#{btc_difference.round(5)} @ $#{current_btc_price.round(2)}"
        elsif btc_difference < 0
          puts "#{formatted_time} SELL ฿#{btc_difference.abs.round(5)} @ $#{current_btc_price.round(2)} = $#{usd_difference.abs.round(2)}"
        end
      end

      usd = new_usd
      btc = new_btc

      # Memorize price for final calculation
      last_price = current_btc_price
    end

    final_amount = usd + (btc * last_price)

    puts "\e[32mRESULT $#{final_amount.round(2)}\e[0m"
    puts
  end
end

if __FILE__ == $0
  Dir['strategies/*rb'].each do |strat|
    require_relative strat
  end
end
