#!/usr/bin/env ruby

require 'csv'
require 'time'
require './time_series.rb'
require 'byebug'

def execute_on_timeseries(&block)
  db = TimeSeries.new
  most_recent_price = nil

  CSV.foreach('btcusd.csv', headers: true, header_converters: :symbol) do |row|
    time = Time.parse(row[:date])

    next if time < Time.parse('2020-01-01') # ignore data before 2020

    most_recent_price = row[:high].to_i
    db << TimeSeries::DataPoint.new(time, most_recent_price)
    db = db.slice(time - 24*60*60, time) # truncate
    recent = db.map(&:data)

    block.call(most_recent_price, recent, time)
  end

  most_recent_price
end

def backtest(p=0.9, q=1.1)
  usd = 100
  btc = 0
  price_paid = nil

  last_price = execute_on_timeseries do |price, recent, time|
    if usd > 0 && price < recent.max * p
      btc = usd.fdiv(price)
      puts "#{time} BUY ฿#{btc.round(5)} worth $#{usd.round(2)} @ $#{price}"
      price_paid = price
      usd = 0
    elsif btc > 0 && price > price_paid * q
      usd = btc * price
      puts "#{time} SELL ฿#{btc.round(5)} worth $#{usd.round(2)} @ $#{price}"
      btc = 0
    end
  end

  puts
  puts "\e[32mRESULT $#{(btc * last_price + usd).round(2)}\e[0m"

end

puts "\e[4mTest 1: Buy when 2% down, sell when 2% up\e[24m"
puts
backtest(0.98, 1.02)
puts
puts "\e[4mTest 2: Buy when 5% down, sell when 5% up\e[24m"
puts
backtest(0.95, 1.05)
puts
puts "\e[4mTest 3: Buy when 10% down, sell when 10% up\e[24m"
puts
backtest(0.9, 1.1)
puts
puts "\e[4mTest 4: Buy when 5% down, sell when 10% up\e[24m"
puts
backtest(0.95, 1.1)
puts
puts "\e[4mTest 5: HODL\e[24m"
puts
backtest(Float::INFINITY, Float::INFINITY)
