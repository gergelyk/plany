
class Coverage
  @coverage_map : Hash(String, Hash(String, AnnotatedSpec))?
  def set_content(coverage_map)
    @coverage_map = coverage_map
  end

  def render(width, height)
    buffers = [] of NcBuffer(Style)
    if !@coverage_map.nil?
      coverage_size = 0
      @coverage_map.not_nil!.each do |title, spec_obj_map|
        spec_obj_map.each do |path, spec_obj|
          coverage_size += 1
          cov_line = NcBufferAligned(Style).new(width, :Default)
          cov_line << title.style(:EvTitle) << " -> "
          if !path.empty?
            cov_line << path.style(:EvContent) << " "
          end
          cov_line << spec_obj.to_s.style(:EvSpecs)
          #cov_line.show
          buffers << cov_line
        end
      end

      cov_empty_line = NcBufferAligned(Style).new(width, :Default)
      cov_empty_line << ""
      (height - coverage_size).times do
        #cov_empty_line.show
        buffers << cov_empty_line
      end
    end
    return buffers
  end
end
