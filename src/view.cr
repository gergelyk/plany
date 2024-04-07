require "./nc"
require "./parser"
require "./themes"
require "./utils"

def blank(n)
  (" " * n)
end


VLINE = "│".style(:Line)
BLANK_SEP = " ".style(:Line)

class ViewSerial
  @days_num = 0
  @vcursor = 0
  @cursor_offset : Int32
  @labels_width = 0
  @window_width = 0
  @max_cursor_offset = 0
  @day_width = 2
  @sep_width = 1
  @last_candidate : Time?

  def initialize(@rows : Hash(String, Hash(String, AnnotatedSpec)), @today : Time, @start_date : Time, @cursor_offset : Int32)
  end

  def set_start_date(date : Time)
    @start_date = date
  end

  def get_last_candidate_year()
    @last_candidate ? @last_candidate.not_nil!.year : nil
  end

  def resize(window_width : Int32)
    @window_width = window_width
    labels_width_min = 13
    labels_width_max = 20
    labels_width_ratio = 5 # preferred 20% of window width
    day_spacing = @day_width + @sep_width
    labels_width = Math.min(labels_width_max, Math.max(labels_width_min, (@window_width // labels_width_ratio)))
    days_num = (@window_width - labels_width) // day_spacing
    @labels_width = @window_width - days_num * day_spacing
    @days_num = days_num
    @max_cursor_offset = Math.max(0, @days_num-1)
    @cursor_offset = Math.min(@cursor_offset, @max_cursor_offset)
  end

  def render_month_year(cursor, line_months, line_days, last_month)
    month = cursor.month
    year = cursor.year
    sep = month != last_month ? VLINE : BLANK_SEP

    if month != last_month
      if line_months.size > line_days.size
        line_months.restore
        line_months << blank Math.max(0, (line_days.size - line_months.size))
      end
      month_s1 = year.to_s
      line_months << sep
      line_months.checkpoint
      line_months << month_s1.style(:Year) << "/"
      month_s2 = month.to_s.rjust(2, '0')
      month_s2 += " " * (@day_width - ((month_s1.size + month_s2.size + 1) % @day_width))
      line_months << month_s2.style(:Month)
    else
      if line_months.size == line_days.size
        month_s = blank @day_width
        line_months << sep << month_s.style(:Month)
      end
    end
    return month, sep
  end

  def render_day(cursor, line_days, line_weekdays, line_separator, month_sep, highlight)
    day_num_s = cursor.day.to_s.rjust(@day_width, '0')
    if highlight
      day_num = day_num_s.style(:DayHlt)
    else
      day_num = day_num_s.style(:Day)
    end
    line_days << month_sep << day_num
    is_first_weekday = cursor.day_of_week == Time::DayOfWeek::Monday
    is_first_displayed = line_weekdays.size == @labels_width
    draw_sep = is_first_weekday || is_first_displayed
    sep_weekdays = draw_sep ? VLINE : BLANK_SEP
    line_weekdays << sep_weekdays
    if cursor.monday?
      week = cursor.calendar_week[1].to_s.rjust(@day_width, '0')
      line_weekdays << week.style(:WeekNum)
    else
      day = cursor.day_of_week.to_s[...@day_width]
      if cursor.saturday? || cursor.sunday?
        line_weekdays << day.style(:Weekend)
      else
        line_weekdays << day.style(:Weekday)
      end
    end

    if draw_sep
      line_separator << "┴──"
    else
      line_separator << "───"
    end
  end

  def render_event(cursor, buf_events, is_first_column, last_covers, covers, highlight)
    sep = cursor.day_of_week == Time::DayOfWeek::Monday || is_first_column ? "│" : " "
    sep_styled = covers && last_covers ? sep.style(:EvFull) : sep
    if highlight
      item = covers ? "##".style(:EvFullCur) : "##".style(:EvEmptyCur)
    else
      item = covers ? "  ".style(:EvFull) : "::".style(:EvEmpty)
    end
    buf_events << sep_styled << item
    return covers
  end

  def render(window_width)
    resize(window_width)

    start_date = @start_date - @cursor_offset.days
    coverage_map = {} of String => Hash(String, AnnotatedSpec)

    if @days_num <= 0
      line_error = NcBuffer(Style).new
      line_error << "Window too small"
      return [line_error], coverage_map, nil
    end

    line_days = NcBuffer(Style).new
    line_months = NcBuffer(Style).new
    line_weekdays = NcBuffer(Style).new
    buf_events = NcBuffer(Style).new
    line_separator = NcBuffer(Style).new

    months_label = " Month "
    line_months << "Year".rjust(@labels_width - months_label.size, ' ').style(:Year) << months_label.style(:Month)
    line_days << "Day ".rjust(@labels_width, ' ').style(:Day)

    weekdays_label = " Weekday "
    line_weekdays << "Week".rjust(@labels_width - weekdays_label.size, ' ').style(:WeekNum) << weekdays_label.style(:Weekday)

    line_separator << "─" * @labels_width

    last_year = 0
    last_month = 0
    cursor = start_date

    @days_num.times do
      highlight = cursor == @today
      last_month, month_sep = render_month_year(cursor, line_months, line_days, last_month)
      render_day(cursor, line_days, line_weekdays, line_separator, month_sep, highlight)
      cursor += 1.day
    end

    if line_months.size != @window_width
      if line_months.size > @window_width
        line_months.restore
      end
      line_months << blank (@window_width - line_months.size)
    end

    @rows.each_with_index do |(title, spec_obj_map), index|
      cursor = start_date
      last_covers = false

      title_field = (title + " ").ltrim(@labels_width-1).rjust(@labels_width, ' ')
      buf_events << title_field.style(index == @vcursor ? Style::EvTitleHlt : Style::EvTitle)

      @days_num.times do |n|
        highlight = n == @cursor_offset
        is_first_column = n == 0

        if highlight
          coverage = spec_obj_map.select {|path, spec_obj| spec_obj.covers?(cursor) }
          coverage_map[title] = coverage
          covers = !coverage.empty?
        else
          covers = spec_obj_map.values.any? &.covers?(cursor)
        end

        last_covers = render_event(cursor, buf_events, is_first_column, last_covers, covers, highlight)
        cursor += 1.day
      end
    end

    buffers = [
      line_months,
      line_days,
      line_weekdays,
      buf_events,
      line_separator,
    ]

    height = buffers.size + coverage_map.size
    return buffers, coverage_map, height
  end

  def shift_date(delta, locked)
    start_date = @start_date + delta
    if !locked
      cursor_offset = @cursor_offset + (start_date - @start_date).days
      @cursor_offset = Math.max(0, Math.min(cursor_offset, @max_cursor_offset))
    end
    @start_date = start_date
  end

  def shift_vcursor(offset)
    @vcursor = Math.min(@rows.size - 1, Math.max(0, @vcursor + offset))
  end

  def find(step : Time::Span, continue : Bool, over_all : Bool)

    candidate = (continue && @last_candidate ? @last_candidate.not_nil! : @start_date) + step
    scanned_year = candidate.year

    loop do

      if over_all
        array_of_iters = @rows.values.each.map &.values.each
        spec_objs = Iterator.chain array_of_iters
      else
        spec_objs = @rows.values[@vcursor].values
      end

      if spec_objs.any? &.covers?(candidate)
        @start_date = candidate
        return true
      end

      next_candidate = candidate + step
      if next_candidate.year != scanned_year
        @last_candidate = candidate
        return false
      end
      candidate = next_candidate
    end
  end

  def find_next(continue, over_all)
    find(+1.day, continue, over_all)
  end

  def find_prev(continue, over_all)
    find(-1.day, continue, over_all)
  end
end


