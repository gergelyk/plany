class StatusLine

  @hints = [] of String
  @msg : Tuple(String, Style)?


  def render(width)
    buf = NcBuffer(Style).new

    if @msg
      msg = @msg.not_nil!
      text, style = msg
      if text.size > width
        buf << (text[...width-1] + "…").style(style)
      else
        buf << msg
      end
    end

    available_size = width - buf.size
    hints_buf = ""
    @hints.each_with_index do |hint, index|
      candidate = (index == 0 ? "" : " ") + "│ " + hint
      if available_size < candidate.size
        break
      end
      available_size -= candidate.size
      hints_buf += candidate
    end

    buf << (" " * (width - buf.size - hints_buf.size)).style(:Hint)
    buf << hints_buf.style(:Hint)

    return buf
  end

  def set_msg(msg : String, style : Style)
    @msg = (msg + " ").style(style)
  end

  def clear_msg
    @msg = nil
  end

  def set_info(msg)
    set_msg(msg, :MsgInfo)
  end

  def set_warn(msg)
    set_msg(msg, :MsgWarn)
  end

  def add_hint(hint)
    @hints << hint
  end

end
