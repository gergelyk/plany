
class String
  def ltrim(size : Int32)
    if self.size > size
      if size == 0
        return ""
      elsif size == 1
        return "…"
      else
        return "…" + self[-size+1..]
      end
    else
      return self
    end
  end
end
