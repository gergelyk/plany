
class SpecBase
  def covers?(date : Time)
    raise "Not implemented"
  end
end

class SpecTriple < SpecBase
  def_equals @year, @month, @day

  def initialize(@year : Int32?, @month : Int32?, @day : Int32?)
  end

  def to_s(io : IO)
    io << "<Triple:#{@year}/#{@month}/#{@day}>"
  end

  def day_specified?
    !@day.nil?
  end

  def complete_from(other : SpecTriple)
    if @year.nil? && !other.@year.nil?
      @year = other.@year
    end
    if @month.nil? && !@day.nil? && !other.@month.nil?
      @month = other.@month
    end
  end

  def greater?(date : Time)
    if !@year.nil?
      if @year.not_nil! > date.year
        return true
      end
      if @year.not_nil! < date.year
        return false
      end
    end

    if @month.nil? && !@year.nil?
      month = 1
    else
      month = @month
    end

    if !month.nil?
      if month.not_nil! > date.month
        return true
      end
      if month.not_nil! < date.month
        return false
      end
    end

    if @day.nil? && !month.nil?
      day = 1
    else
      day = @day
    end

    if !day.nil?
      if day.not_nil! > date.day
        return true
      end
    end

    return false
  end

  def lower?(date : Time)
    if !@year.nil?
      if @year.not_nil! < date.year
        return true
      end
      if @year.not_nil! > date.year
        return false
      end
    end

    if @month.nil? && !@year.nil?
      month = 12
    else
      month = @month
    end

    if !month.nil?
      if month.not_nil! < date.month
        return true
      end
      if month.not_nil! > date.month
        return false
      end
    end

    if @day.nil? && !month.nil?
      # last day of the month
      day = (Time.utc(date.year, month.not_nil! + 1, 1, 0, 0, 0) - 1.day).day
    else
      day = @day
    end

    if !day.nil?
      if day.not_nil! < date.day
        return true
      end
    end
    return false
  end

  def covers?(date : Time)
    if !@year.nil?
      if @year != date.year
        return false
      end
    end
    if !@month.nil?
      if @month != date.month
        return false
      end
    end
    if !@day.nil?
      if @day != date.day
        return false
      end
    end
    return true
  end
end

class SpecWeekday < SpecBase
  def_equals @index

  def initialize(@index : Int32)
  # 1 = monday, 7 = sunday
  end

  def to_s(io : IO)
    io << "<Weekday:#{@index}>"
  end

  def covers?(date : Time)
    date.day_of_week.to_i == @index
  end
end

class SpecRange < SpecBase
  def_equals @start, @stop

  def initialize(@start : SpecTriple?, @stop : SpecTriple?)
  end

  def to_s(io : IO)
    io << "<Range:"
    @start.to_s(io)
    io << ","
    @stop.to_s(io)
    io << ">"
  end

  def covers?(date : Time)
    if @start.nil? & @stop.nil?
      return true
    else
      if !@start.nil?
        if @start.not_nil!.greater?(date)
          return false
        end
      end
      if !@stop.nil?
        if @stop.not_nil!.lower?(date)
          return false
        end
      end
      return true
    end
  end
end

class SpecNot < SpecBase
  def_equals
  def initialize(@spec : SpecBase)
  end

  def to_s(io : IO)
    io << "<Not:"
    @spec.to_s(io)
    io << ">"
  end

  def covers?(date : Time)
    !@spec.covers?(date)
  end
end

class SpecOr < SpecBase
  def_equals @specs
  def initialize(@specs : Array(SpecBase))
  end

  def to_s(io : IO)
    io << "<Or:["
    @specs.each do |s|
      s.to_s(io)
      io << ","
    end
    io << "]>"
  end

  def covers?(date : Time)
    @specs.each do |s|
      if s.covers?(date)
        return true
      end
    end
    return false
  end
end

class SpecAnd < SpecBase
  def_equals @specs
  def initialize(@specs : Array(SpecBase))
  end

  def to_s(io : IO)
    io << "<And:["
    @specs.each do |s|
      s.to_s(io)
      io << ","
    end
    io << "]>"
  end

  def covers?(date : Time)
    @specs.each do |s|
      if !s.covers?(date)
        return false
      end
    end
    return true
  end
end
