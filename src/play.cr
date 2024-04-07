require "log"
require "fancyline"
require "./parser"

def play(start_date="today", years_ahead=100)
  examples = "Valid examples:
  22
  2022
  5/22
  2022/5
  2022/5/22
  wednesday
  wed
  September
  sep
  se
  m9
  q2
  daily
  "

  fancy = Fancyline.new
  parse_error = nil

  fancy.sub_info.add do |ctx, yielder|
    lines = yielder.call(ctx) # First run the next part of the middleware chain
    ctx.editor.fancyline.tty.clear_screen

    rows = ctx.editor.fancyline.tty.rows-1
    row = 0

    if spec = ctx.editor.line

      begin
        spec_obj = parse_spec(spec)
      rescue ex: ParsePrimitiveError
        lines << ex.to_s.colorize(:red).to_s
        row = row + 1

        examples.split('\n').each do |line|
          lines << line.colorize(:light_blue).to_s
          row = row + 1
        end

        parse_error = ex

      else
        lines << spec_obj.to_s.colorize(:light_blue).to_s
        row = row + 1

        if start_date == "today"
          current = Time.local
          start = Time.utc(current.year, current.month, current.day, 0, 0, 0)
        else
          begin
            start_nums = start_date.split(separator: '/').map(&.to_i32) + [1]*2
          rescue
            raise "Invalid date: " + start_date
          end
          start = Time.utc(start_nums[0], start_nums[1], start_nums[2], 0, 0, 0)
        end
        stop = Time.utc(start.year + years_ahead, 12, 31, 0, 0, 0)

        cursor = start
        while cursor <= stop
          if spec_obj.covers?(cursor)
            if row < rows-1
              lines << cursor.to_s("%Y/%m/%d %a")
            elsif row == rows-1
              lines << "..."
            else
              break
            end
            row = row + 1
          end
          cursor = cursor + 1.days
        end

        parse_error = nil
      end
    end

    (rows-row).times do |x|
      lines << ""
    end

    lines # Return the lines so far
  end

  fancy.display.add do |ctx, line, yielder|
    if spec = ctx.editor.line
      line = line.colorize(parse_error ? :red : :green).to_s
    end
    yielder.call ctx, line
  end

  begin
    while input = fancy.readline("> ")
    end
  rescue Fancyline::Interrupt
  end

  fancy.tty.clear_screen

end