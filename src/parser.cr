require "log"
require "./models"

class ParsePrimitiveError < Exception
end

class ParseTripleError < ParsePrimitiveError
end

class ParseLiteralError < ParsePrimitiveError
end

class ParsePrefixError < ParsePrimitiveError
end

class ParseRangeError < ParsePrimitiveError
end


def parse_digits(spec)
  digits_str = spec.split '/'
  begin
    digits = digits_str.map { |x| x.to_u32.to_i32 }
  rescue
    raise ParseTripleError.new("Invalid integers: \"#{spec}\"")
  end

  case digits.size
  when 1
    if digits[0] > 31
      spec_obj = SpecTriple.new digits[0], nil, nil
    else
      spec_obj = SpecTriple.new nil, nil, digits[0]
    end
  when 2
    if digits[0] > 12
      spec_obj = SpecTriple.new digits[0], digits[1], nil
    else
      spec_obj = SpecTriple.new nil, digits[0], digits[1]
    end
  when 3
    spec_obj = SpecTriple.new digits[0], digits[1], digits[2]
  else
    raise ParseTripleError.new("Too many digits: \"#{spec}\"")
  end
  return spec_obj
end

def parse_literal(spec)
  months = "january february march april may jun july august september october november december".split
  months3 = "jan feb mar apr may jun jul aug sep oct nov dec".split
  months2 = "ja fe mr ap my jn jl au se oc no de".split
  weekdays = "monday tuesday wednesday thursday friday saturday sunday".split
  weekdays3 = "mon tue wed thu fri sat sun".split
  weekdays2 = "mo tu we th fr sa su".split

  months_all = [*months, *months3, *months2]
  weekdays_all = [*weekdays, *weekdays3, *weekdays2]

  if spec == "daily"
    spec_obj = SpecRange.new(nil, nil)
  elsif months_all.includes?(spec)
    index = months_all.index(spec).not_nil! % months.size
    spec_obj = SpecTriple.new nil, index + 1, nil
  elsif weekdays_all.includes?(spec)
    index = weekdays_all.index(spec).not_nil! % weekdays.size
    spec_obj = SpecWeekday.new index + 1
  else
    raise ParseLiteralError.new("Unknown literal: \"#{spec}\"")
  end
  return spec_obj
end

def parse_prefix(spec)
  prefix = spec[0]
  num = spec[1..].to_i32

  case prefix
  when 'q'
    case num
    when 1
      spec_obj = SpecRange.new SpecTriple.new(nil, 1, 1), SpecTriple.new(nil, 3, 31)
    when 2
      spec_obj = SpecRange.new SpecTriple.new(nil, 4, 1), SpecTriple.new(nil, 6, 30)
    when 3
      spec_obj = SpecRange.new SpecTriple.new(nil, 7, 1), SpecTriple.new(nil, 9, 30)
    when 4
      spec_obj = SpecRange.new SpecTriple.new(nil, 10, 1), SpecTriple.new(nil, 12, 31)
    else
      raise ParsePrefixError.new("Incorrect quarter: \"#{spec}\"")
    end
  when 'm'
    spec_obj = SpecTriple.new nil, num, nil
  else
    raise ParsePrefixError.new("Unknown prefix: \"#{spec}\"")
  end

  return spec_obj
end

def parse_primitive(spec)

  case spec
  when /^[\d\/]+$/
    spec_obj = parse_digits(spec)
  when /^[a-z]+$/
    spec_obj = parse_literal(spec)
  when /^[a-z]\d+$/
    spec_obj = parse_prefix(spec)
  else
    raise ParsePrimitiveError.new("Primitive not recognized: \"#{spec}\"")
  end

  return spec_obj
end

def parse_range(spec)
  primitives = spec.split('-')

  case primitives.size
  when 1
    spec_obj = parse_primitive(spec)
  when 2
    if primitives[0].empty?
      left = nil
    else
      left = parse_digits(primitives[0])

      # if !left.day_specified?
      #   raise ParseRangeError.new("At least day must be specified: #{primitives[0]}")
      # end
    end

    if primitives[1].empty?
      right = nil
    else
      right = parse_digits(primitives[1])

      # if !right.day_specified?
      #   raise ParseRangeError.new("At least day must be specified: #{primitives[1]}")
      # end

      if !left.nil?
        right.complete_from(left)
      end
    end
    spec_obj = SpecRange.new(left, right)
  else
    raise ParseRangeError.new("Too many range operators: \"#{spec}\"")
  end

  return spec_obj
end

def parse_not(spec)
  if spec.starts_with?('!')
    spec_obj = SpecNot.new(parse_range(spec[1..]))
  else
    spec_obj = parse_range(spec)
  end

  return spec_obj
end

def parse_alternative(spec)
  specs = (spec.split ',').map { |x| parse_not(x) }
  if specs.size == 1
    spec_obj = specs[0]
  else
    spec_obj = SpecOr.new(specs)
  end

  return spec_obj
end

def parse_conjunction(spec)
  specs = (spec.split ' ').map { |x| parse_alternative(x) }
  if specs.size == 1
    spec_obj = specs[0]
  else
    spec_obj = SpecAnd.new(specs)
  end

  return spec_obj
end

def parse_spec(spec)
  spec_obj = parse_conjunction(spec.strip.downcase.gsub /\s+/, " ")
  Log.debug { "\"#{spec}\" -> #{spec_obj}" }
  return spec_obj
end

def parse_specs(specs)
  spec_objs = specs.map { |s| parse_spec(s) }
  if spec_objs.size == 1
    return spec_objs[0]
  else
    return SpecOr.new(spec_objs)
  end
end

