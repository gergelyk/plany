require "ncurses"
require "xdg_base_directory"
require "./view"
require "./loader"
require "./scanner"
require "./agregator"
require "./status"
require "./coverage"
require "yaml"

def initialize()

  app_name = "plany"
  xdg_dirs = XdgBaseDirectory::XdgDirs.new(app_name) 

  views = xdg_dirs.config.file_path("views.yaml")
  paths = File.open(views) do |file|
  YAML.parse(file)["default"]
  end

  now = Time.local
  today = Time.utc(now.year, now.month, now.day, 0, 0, 0)

  loader = Loader.new
  tree = loader.load_dir(xdg_dirs.data.to_s())

  scanner = Scanner.new
  scanner.scan(tree)
  agregator = Agregator.new scanner.@generators

  rows = {} of String => Hash(String, AnnotatedSpec)
  paths.as_a.each do |path|
    rows = rows.merge agregator.select path.to_s
  end

  view = ViewSerial.new(rows, today, start_date=today, cursor_offset=10)

  status = StatusLine.new
  status.add_hint "t:today"
  status.add_hint "↑↓jk:select"
  status.add_hint "←→hHlL:find"
  status.add_hint ",. move day"
  status.add_hint "<> week"
  status.add_hint "[] month"
  status.add_hint "{} year"

  coverage = Coverage.new

  return view, coverage, status, today
end

def set_status(status, view, event, found)
  if found == true
    status.set_info "Event found"
  elsif found == false
    status.set_warn "No more events found in " + view.get_last_candidate_year.to_s + ", press " + event.to_s + " to continue searching"
  end
end

def render(view, coverage, status, event, found)
  all_buffers = [] of Array(NcBuffer(Style))

  buffers, coverage_map, height = view.render NCurses.width
  all_buffers << buffers
  #buffers.each &.show

  if !height.nil?
    coverage.set_content coverage_map
    buffers = coverage.render(NCurses.width, NCurses.height - height)
    all_buffers << buffers

    set_status(status, view, event, found)
    buffer = status.render(NCurses.width)
    all_buffers << [buffer]
  end

  all_buffers.each do |buffers|
    buffers.each &.show
  end
end

def main()
  nc_app = NcApp(Style).new
  nc_app.run do

    apply_theme_dark(nc_app)

    locked = true
    last_event = nil
    last_found = nil

    view, coverage, status, today = initialize

    nc_app.repeat do |event|

      continue = last_found == false && event == last_event
      found = nil
      status.clear_msg

      case event
      when 'q'
        break
      when '/'
        locked = !locked
        status.set_info "Cursor " + (locked ? "locked" : "unlocked")
      when 't'
        view.set_start_date today
      when ','
        view.shift_date(-1.day, locked)
      when '.'
        view.shift_date(+1.day, locked)
      when '<'
        view.shift_date(-1.week, locked)
      when '>'
        view.shift_date(+1.week, locked)
      when '['
        view.shift_date(-1.month, locked=true)
      when ']'
        view.shift_date(+1.month, locked=true)
      when '{'
        view.shift_date(-1.year, locked=true)
      when '}'
        view.shift_date(+1.year, locked=true)
      when 'j', NCurses::Key::Down
        view.shift_vcursor(+1)
      when 'k', NCurses::Key::Up
        view.shift_vcursor(-1)
      when 'l', NCurses::Key::Right
        found = view.find_next(continue, over_all=false)
      when 'h', NCurses::Key::Left
        found = view.find_prev(continue, over_all=false)
      when 'L'
        found = view.find_next(continue, over_all=true)
      when 'H'
        found = view.find_prev(continue, over_all=true)
      else nil
        # resize window
      end

      render(view, coverage, status, event, found)

      last_event = event
      last_found = found

    end

  end
end
