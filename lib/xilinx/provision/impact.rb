require 'tmpdir'

# :nodoc namespace
module Xilinx

# :nodoc namespace
module Provision

# Runs the impact tool.
module Impact
  # Runs the impact tool and returns the status.
  #
  # The options argument accepts the following keys:
  #   :batch:: array of commands to be written to a batch file and executed
  #   :mode:: device configuration mode (try :bscan for JTAG boundary scan)
  #   :cable_port:: (try :auto)
  #
  # Returns the command's output.
  def self.run(options = {})
    unless command_line = path
      raise "Xilinx ISE not found\nPlease download from #{download_url}"
    end
    
    command_line << " -mode #{options[:mode]}" if options[:mode]
    command_line << " -port #{options[:cable_port]}" if options[:cable_port]
    
    output = nil
    Dir.mktmpdir do |temp_dir|
      Dir.chdir temp_dir do
        if options[:batch]
          File.open('impact_batch', 'wb') do |f|
            f.write options[:batch].map { |line| line + "\n" }.join
          end
          command_line << ' -batch impact_batch'
        end
        command_line << ' 2>&1'
        output = Kernel.`(command_line)
      end 
    end
    output
  end
  
  # Path to the impact binary.
  def self.path
    @path ||= path!
  end
  
  # Cached path.
  @path = nil
  
  # Path to the impact binary.
  #
  # This method does not cache its result and is really slow.
  def self.path!
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
    'http://www.xilinx.com/support/download/index.htm'
  end
end  # namespace Xilinx::Provision::Impact

end  # namespace Xilinx::Provision

end  # namespace Xilinx
