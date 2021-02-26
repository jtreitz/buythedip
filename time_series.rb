class TimeSeries
  include Enumerable

  attr_reader :data_points

  class DataPoint
    include Comparable
  
    attr_reader :timestamp, :data
  
    def initialize(timestamp, data)
      timestamp = timestamp.to_time unless timestamp.kind_of? Time
      @timestamp, @data = timestamp, data
    end
  
    def <=>(another)
      result = @timestamp <=> another.timestamp
    end
  
    def ==(another)
      @timestamp == another.timestamp and @data == another.data
    end
  end

  def initialize(data_points={})
    @data_points = data_points
  end

  def << (*data_points)
    data_points.flatten.each do |data_point|
      @data_points[data_point.timestamp] = data_point
    end
  end

  def slice(from, to)
    data_points = @data_points.select do |t|
      t >= from and t <= to
    end
    self.class.new data_points
  end

  def each(&block)
    to_a.each(&block)
  end

  def length
    @data_points.length
  end

  def to_a
    Hash[@data_points.sort].values
  end
end