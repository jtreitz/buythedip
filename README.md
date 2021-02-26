# Run script

### All strategies
```
ruby btd.rb
```

### One strategy
```
ruby strategies/<file>

ruby strategies/hodl_and_buy_more.rb
```

# Output
```
There's a new investor in town! They start with $0 and ฿0, adding $100 to their budget every 1st of the month.


Strategy: Purchase when price went down 10.0%, sell when price goes up 10.0%
RESULT $2087.93


Strategy: Purchase when price went down 20.0%, sell when price goes up 20.0%
RESULT $1471.93


Strategy: Purchase when price went down 5.0%, sell when price goes up 5.0%
RESULT $2928.4


Strategy: HODLAndBuyMore
RESULT $6502.48


Strategy: I don't like Bitcoin
RESULT $1400


Strategy: BuyEvery30Days
RESULT $6510.88
```

# Submit your own
* Make a new file under `strategies/`. 
* Import the main file via `require_relative '../btd.rb'`
* Implement a class inheriting from `Strategy`
* Implement the `#execute` method (see other strategies for signature)
* (optional) Implement the `#description` method
* Call `Investor#run` at the end of your file
* To test, run with `ruby strategies/<your_file_name>`

See the examples in `strategies/`

# tl;dr

HODL
