require "ncurses"

class NcBuffer(S)
  getter size
  @checkpoint_seq_size : Int32?
  @checkpoint_str_size = 0

  def initialize
    @size = 0
    @sequence = [] of Tuple(String, S)
  end

  def <<(item : String)
    @sequence << {item, S::Default}
    @size += item.size
    self
  end

  def <<(item : Tuple(String, S))
    @sequence << item
    @size += item[0].size
    self
  end

  def checkpoint
    @checkpoint_seq_size = @sequence.size
    @checkpoint_str_size = @size
  end

  def restore
    if @checkpoint_seq_size
      @sequence = @sequence[...@checkpoint_seq_size]
      @size = @checkpoint_str_size
      @checkpoint_seq_size = nil
    end
  end

  def show
    @sequence.each do |text, style|
      NCurses.set_color style
      NCurses.print text
    end
  end

  def show(width : Int32, fill_style : S)
    size = 0
    @sequence.each_with_index do |(text, style), index|
      NCurses.set_color style
      if size + text.size > width || (size + text.size == width && index + 1 < @sequence.size)
        NCurses.print text[...(width - size - 1)]
        NCurses.print "…"
        size += width - size
        break
      else
        NCurses.print text
        size += text.size
      end

    end
    NCurses.set_color fill_style
    NCurses.print " " * (width - size)
  end

end

class NcBufferAligned(S) < NcBuffer(S)

  def initialize(@width : Int32, @fill_style : S)
    super()
  end

  def show()
    size = 0
    @sequence.each_with_index do |(text, style), index|
      NCurses.set_color style
      if size + text.size > @width || (size + text.size == @width && index + 1 < @sequence.size)
        NCurses.print text[...(@width - size - 1)]
        NCurses.print "…"
        size += @width - size
        break
      else
        NCurses.print text
        size += text.size
      end

    end
    NCurses.set_color @fill_style
    NCurses.print " " * (@width - size)
  end
end


class NcApp(S)

  def run(&)
    NCurses.start
    NCurses.cbreak
    NCurses.no_echo
    NCurses.set_cursor :Invisible
    NCurses.keypad(true)

    unless NCurses.has_colors?
        NCurses.end
        raise "Colors not supported"
    end

    NCurses.start_color
    begin
      yield
    ensure
      NCurses.end
    end
  end

  def repeat(&)
    NCurses.clear
    yield nil

    NCurses.get_char do |event|
        NCurses.clear
        yield event
    end
  end


  def paint(style : S, fg_color : NCurses::Color, bg_color : NCurses::Color)
    NCurses.init_color_pair(style, fg_color, bg_color)
  end

end
