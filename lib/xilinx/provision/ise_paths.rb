# :nodoc namespace
module Xilinx

# :nodoc namespace
module Provision

# Manages the local ISE installation.
module IsePaths
  # Path to the impact binary.
  def self.impact_path
    @impact_path ||= impact_path!
  end
  
  # Cached path.
  @impact_path = nil
  
  # Path to the impact binary.
  #
  # This method does not cache its result and is really slow.
  def self.impact_path!
    paths = Dir['/opt/**/impact']
    paths = Dir['/usr/**/impact'] if paths.empty?
    
    # 1 is a Fixnum which is a pointer, so its size shows 32/64-bit
    if 1.size == 8
      paths = paths.select { |path| path.index '64' }
    else
      paths = paths.reject { |path| path.index '64' }
    end
    
    paths.sort.last
  end
  
  # The URL printed when no ISE installation is found.
  def self.download_url
    "http://www.xilinx.com/support/download/index.htm"
  end
end

end  # namespace Xilinx::Provision

end  # namespace Xilinx
