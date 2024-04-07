require "./parser"
require "./models"

class Array(T)
  def starts_with(prefix : Array(T))
    prefix.zip?(self).each do |p, s|
      if p != s
        return false
      end
    end
    return true
  end
end

class AnnotatedSpec

    @spec_obj : SpecBase

  def initialize(@specs : Array(String))
    @spec_obj = parse_specs @specs
  end

  def covers?(date : Time)
    @spec_obj.covers?(date)
  end

  def to_s
    @specs.join " | "
  end
end

class Agregator

  def initialize(@generators : Hash(Array(String), Array(String)))
  end

  def select(path : String)
    path_a = path.split("/")
    selected = @generators.keys.select! { |x| x.starts_with path_a }

    #paths = selected.map { |p| p[path_a.size...].join('/')[...15] } # TODO: items with the same digist appear once
    paths = selected.map { |p| p[path_a.size...].join('/') }
    spec_objs = selected.map { |p| AnnotatedSpec.new(@generators[p]) }

    return {path => Hash.zip(paths, spec_objs)}
  end

end
