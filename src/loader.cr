require "log"
require "yaml"

class Loader

  def load_file(path)
    Log.debug { "Loading file: #{path}" }
    yaml = File.open(path) do |file|
      return YAML.parse(file)
    end
  end

  def load_dir(path)
    Log.debug { "Loading dir: #{path}" }
    branch = {} of YAML::Any => YAML::Any
    dir = Dir.new(path)
    dir.children.sort.each do |child|
      child = File.new(Path.new(dir.path, child))
      child_info = child.info
      case child_info
      when .directory?
        branch[YAML::Any.new(Path.new(child.path).stem)] = load_dir(child.path)
      when .file?
        branch[YAML::Any.new(Path.new(child.path).stem)] = load_file(child.path)
      else
        Log.debug { "Skiping: #{child.path}" }
      end
    end
    return YAML::Any.new branch
  end

end
