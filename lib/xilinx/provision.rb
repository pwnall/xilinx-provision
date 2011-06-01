# :nodoc: namespace
module Xilinx

# Documentation here.
module Provision
  # Programs an FPGA chip on a JTAG chain.
  #
  # The options argument accepts the following keys:
  #   :cable_port:: set to :auto by default
  #
  # Raises an exception if programming fails, returns true otherwise.
  def self.fpga(bitfile, options = {})
    if output = Xilinx::Provision::Impact.program_fpga(bitfile, options)
      raise "Failed to program device!\nCommand output:\n#{output}"
    end
    true
  end
end  # namespace Xilinx::Provision

end # namespace Xilinx

require 'xilinx/provision/cable_driver.rb'
require 'xilinx/provision/cable_firmware.rb'
require 'xilinx/provision/impact.rb'
require 'xilinx/provision/udev.rb'
