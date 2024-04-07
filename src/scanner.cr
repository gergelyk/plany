require "log"

class ScanningError < Exception
end

class Scanner

  def initialize
    @generators = {} of Array(String) => Array(String)
  end

  private def register(path, spec)
    path_str = "/" + path.join "/"
    Log.debug { "Registering \"#{path_str}\" : \"#{spec}\"" }
    if @generators.has_key? path
      @generators[path] += spec 
    else
      @generators[path] = spec
    end
  end

  # Convert any scalar from YAML to string
  private def scalar_to_str(v)
    case v
    when .as_s?
      return v.as_s
    when .as_i?
      return v.as_i.to_s
    #when .as_f?
    #  return v.as_f.to_s
    else
      return nil
    end
  end

  # convert array of YAML scalars into array of strings
  private def a_to_str(a)
    a_str = [] of String

    a.as_a.each do |av|
      if av_str = scalar_to_str(av)
        a_str << av_str
      else
        return nil
      end
    end
    return a_str
  end

  private def scan_branch(branch, path)
    path_str = "/" + path.join "/"

    case branch
    when .as_h?
      branch.as_h.each do |k, v|
        if !(k_str = scalar_to_str(k))
          raise ScanningError.new("Incorrect key: #{k}")
          # next
        end

        case v
        when .as_s?
          register([*path, v.as_s], [k_str])
        when .as_a?
          if a_str = a_to_str(v)
            register([*path, k_str], a_str)
          else
            v.as_a.each do |av|
              scan_branch(av, [*path, k_str])
            end
          end
        else
          scan_branch(v, [*path, k_str])
        end
      end
    else
      raise ScanningError.new("Incorrect branch: \"#{path_str}/#{branch}\"")
    end

  end

  def scan(tree)
    scan_branch(tree, [] of String)
  end

  def select(path)
    selection = {} of Array(String) => String
    @generators.each do |k, v|
      if k[0...path.size] == path
        selection[v] = k[path.size..] .join '.'
      end
    end
    return selection
  end
end


