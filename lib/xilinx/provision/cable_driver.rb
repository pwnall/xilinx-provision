require 'English'
require 'fileutils'
require 'tmpdir'

# :nodoc namespace
module Xilinx

# :nodoc namespace
module Provision

# Drives the setup of the USB cable driver needed to talk to Xilinx boards.
module CableDriver
  # Performs all the setup needed for the USB cable driver.
  #
  # Returns a false value in case of success, or a string with error information
  # if something goes wrong.
  def self.setup
    if output = build_prerequisites
      return "Error while obtaining driver prerequisites:\n#{output}"
    elsif output = build(path)
      return "Error while building driver:\n#{output}"
    elsif output = configure_udev
      return "Error while configuring cable driver udev rules\n#{output}"
    elsif output = Xilinx::Provision::Udev.reload_rules
      return "Error while loading cable driver udev rules\n#{output}"
    end
    nil
  end
  
  # Installs the packages needed to build the cable driver.
  #
  # Returns a false value for success, and a string containing error output if
  # the build goes wrong.
  def self.build_prerequisites
    if File.exist?(`which apt-get`.strip)
      # The literal `apt-get ...` doesn't use Kernel.` and can't be stubbed.
      output = Kernel.`(
          'apt-get install -y git-core libusb-dev build-essential fxload 2>&1')
      $CHILD_STATUS.to_i == 0 ? nil : output
    else
      "Unsupported OS / distribution\n"
    end
  end
  
  # Builds the cable driver.
  #
  # Assumes the build requirements have been installed by build_prerequisites.
  #
  # Args:
  #   target_path:: directory that will contain the driver
  #
  # Returns the command's output.
  def self.build(target_path)
    target_path = File.expand_path target_path
    Dir.mktmpdir do |temp_dir|
      Dir.chdir temp_dir do
        output = `git clone -q #{git_url} 2>&1`
        return output if $CHILD_STATUS.to_i != 0
        Dir.chdir 'usb-driver' do
          output = `make all 2>&1`
          return output if $CHILD_STATUS.to_i != 0
          FileUtils.cp 'libusb-driver.so', target_path
        end
      end 
    end
    nil
  end

  # Sets up the udev daemon to allow non-root access to the USB cable.
  def self.configure_udev
    Xilinx::Provision::Udev.add_rules udev_rules, '71-xilinx-usb-cable'
    nil
  end
  
  # Rules for the udev daemon to allow non-root access to the USB cable.
  #
  # Returns an array of rules to be written to a udev file.
  def self.udev_rules
    ['ACTION=="add", SUBSYSTEMS=="usb", ATTRS{idVendor}=="03fd", MODE="666"']
  end
  
  # The path to the driver file.
  def self.path
    File.expand_path '../libusb-driver.so', Xilinx::Provision::Impact.path
  end
  
  # The URL printed when no ISE installation is found.
  def self.git_url
    'git://git.zerfleddert.de/usb-driver'
  end
end  # namespace Xilinx::Provision::CableDriver

end  # namespace Xilinx::Provision

end  # namespace Xilinx
