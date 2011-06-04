# :nodoc namespace
module Xilinx

# :nodoc namespace
module Provision

# Finds firmware files for the Xilinx USB cable and sets up automatic uploading.
#
# The USB cables are weird beasts. A cable contains a small FPGA that must be
# programmed every time the cable is powered up, which happens on every
# connection to the computer.
#
# Xilinx ISE ships with the firmware for all cable types, but it doesn't
# automatically upload the firmware when needed. Udev to the rescue!
module CableFirmware
  # Performs all the setup needed for automated firmware upload.
  #
  # Returns a false value in case of success, or a string with error information
  # if something goes wrong.
  def self.setup
    if output = configure_udev
      return "Error while configuring firmware upload udev rules\n#{output}"
    elsif output = Xilinx::Provision::Udev.reload_rules
      return "Error while loading firmware upload udev rules\n#{output}"
    end
    nil
  end
  
  # Sets up the udev daemon to allow non-root access to the USB cable.
  def self.configure_udev
    Xilinx::Provision::Udev.add_rules udev_rules,
                                      '71-xilinx-usb-firmware-upload'
    nil
  end
  
  # Rules for the udev daemon to allow non-root access to the USB cable.
  #
  # Returns an array of rules to be written to a udev file.
  def self.udev_rules
    return nil unless path = rules_path
    old_rules = File.read(rules_path).split("\n")
    upgrade_rules old_rules, path
  end
  
  # Returns a 
  def self.upgrade_rules(old_rules, rules_path)
    rules_dir = File.dirname rules_path
    old_rules.map do |old_rule|
      rule = old_rule.dup
      # Update old udev syntax.
      [['TEMPNODE', 'tempnode'], ['SYSFS', 'ATTRS'], ['"666"', '"0666"'],
       ['BUS', 'SUBSYSTEMS']].each { |from, to| rule.gsub! from, to }
      
      # Change firmware file references to point inside Xilinx ISE. It's very
      # rude to copy crap straigt into /usr/share, Xilinx!
      rule.gsub!(/ \S+\.hex /) do |filepath|
        firmware_name = File.basename filepath.strip
        " #{File.join(rules_dir, firmware_name)} "
      end
      
      rule
    end
  end
  
  # The path to the firmware upload rules file that ships with ISE.
  #
  # This file is written in old-style udev, so it needs to be converted.
  #
  # Returns a path to the rules file, or nil if the file cannot be found.
  def self.rules_path
    dir_path = Xilinx::Provision::Impact.path
    until dir_path == '/' || dir_path.empty?
      dir_path = File.dirname dir_path
      matches = Dir[File.join(dir_path, '**', '*.rules')]
      next if matches.empty?
      if matches.length > 1
        better_matches = Dir[File.join(dir_path, '**', 'xusbdfwu.rules')]
        matches = better_matches unless better_matches.empty?
      end
      return matches.sort.last
    end
    nil
  end
end  # namespace Xilinx::Provision::CableFirmware

end  # namespace Xilinx::Provision

end  # namespace Xilinx
