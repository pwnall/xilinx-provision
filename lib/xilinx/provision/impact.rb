require 'tmpdir'

# :nodoc namespace
module Xilinx

# :nodoc namespace
module Provision

# Runs the impact tool.
module Impact
  # Programs an FPGA chip on a JTAG chain.
  #
  # The options argument accepts the following keys:
  #   :cable_port:: set to :auto by default
  #
  # Returns a false value for success, or a string containing error output if
  # something goes wrong.
  def self.program_fpga(bitfile, options = {})
    options = { :mode => :bscan }.merge options
    options[:cable_port] ||= :auto
    devices = identify_chain(options)
    
    batch = [
      'identify',
      "assignFile -position #{devices.length} -file #{bitfile}",
      "program -position #{devices.length}",
      'cleanCableLock',
      'closeCable'
    ]
    options.merge! :batch => batch
    output = run options
    $CHILD_STATUS.to_i == 0 ? nil : output
  end
  
  # Scans the JTAG chain and returns the devices on it.
  #
  # The options argument accepts the following keys:
  #   :cable_port:: set to :auto by default
  #
  # Returns the command's output.
  def self.identify_chain(options = {})
    batch = ['identify', 'cleanCableLock', 'closeCable']
    options = {:mode => :bscan, :cable_port => :auto, :batch => batch}
    parse_identify run(options)
  end
  
  # Extracts a JTAG chain from an impact identify command.
  #
  # Args:
  #   output:: the impact command output, obtained from Impact#run
  #
  # Returns an array of hashes with the following keys:
  #   name:: the device name, e.g. "Xilinx xc5vlx110t"
  #   version:: number reported by impact
  def self.parse_identify(output)
    lines = output.split("\n").each(&:strip!)
    lines.each_with_index do |line, index|
      if /ident.*chain/i =~ line
        lines = lines[index..-1]
        break
      end
    end
    
    device_id_regexp = /'(\d+)':.*manufacturer.* id.*=([^,]+),.*version.*(\d+)/i
    devices = []
    device = {}
    lines.each do |line|
      if match = device_id_regexp.match(line)
        device[:index] = match[1].to_i
        device[:name] = match[2].strip
        device[:version] = match[3].to_i
      end
      if /^\-+$/ =~ line && !device.empty?
        devices << device
        device = {}
      end
    end
    devices
  end
  
  # Runs the impact tool and returns the status.
  #
  # The options argument accepts the following keys:
  #   :batch:: array of commands to be written to a batch file and executed
  #   :mode:: device configuration mode (try :bscan for JTAG boundary scan)
  #   :cable_port:: (try :auto)
  #
  # Returns the command's output.
  def self.run(options = {})
    unless command_line =
        "LD_PRELOAD=#{Xilinx::Provision::CableDriver.path} " + path
      raise "Xilinx ISE not found\nPlease download from #{download_url}"
    end
    
    batch = options[:batch] && options[:batch].dup
    
    if options[:cable_port]
      command_line << " -port #{options[:cable_port]}"
      batch.unshift "setCable -port #{options[:cable_port]}" if batch
    end
    if options[:mode]
      command_line << " -mode #{options[:mode]}"
      batch.unshift "setMode -#{options[:mode]}" if batch
    end
    batch.push 'quit' if batch && batch.last != 'quit'
    
    output = nil
    Dir.mktmpdir do |temp_dir|
      Dir.chdir temp_dir do
        if options[:batch]
          File.open('impact_batch', 'wb') do |f|
            f.write batch.map { |line| line + "\n" }.join
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
