require "ncurses"

enum Style
  Default
  Line
  Year
  Month
  Day
  DayHlt
  Weekday
  Weekend
  WeekNum
  EvEmpty
  EvFull
  EvEmptyCur
  EvFullCur
  EvTitle
  EvTitleHlt
  EvContent
  EvSpecs
  MsgInfo
  MsgWarn
  Hint
end

class String
  def style(s : Style)
    {self, s}
  end
end


def apply_theme_dark(app)
  background = NCurses::Color::Black
  app.paint(:Line,         :White,   background)
  app.paint(:Year,         :Green,   background)
  app.paint(:Month,        :White,   background)
  app.paint(:Day,          :Blue,    background)
  app.paint(:DayHlt,       :Black,   :Blue)
  app.paint(:Weekday,      :White,   background)
  app.paint(:Weekend,      :Red,     background)
  app.paint(:WeekNum,      :Green,   background)
  app.paint(:EvEmpty,      :Blue,    background)
  app.paint(:EvFull,       :Black,   :Red)
  app.paint(:EvEmptyCur,   :Yellow,  background)
  app.paint(:EvFullCur,    :Yellow,  :Red)
  app.paint(:EvTitle,      :Yellow,  background)
  app.paint(:EvTitleHlt,   :Black,   :Yellow)
  app.paint(:EvContent,    :Green, background)
  app.paint(:EvSpecs,      :White,    background)
  app.paint(:MsgInfo,      :Black,    :Blue)
  app.paint(:MsgWarn,      :Black,    :Magenta)
  app.paint(:Hint,         :Black,    :Blue)
end
