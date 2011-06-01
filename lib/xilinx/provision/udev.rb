require 'English'

# :nodoc namespace
module Xilinx

# :nodoc namespace
module Provision

# Runs the impact tool.
module Udev
  # Installs a group of udev rules.
  def self.add_rules(rules, group_name)
    file = File.join rules_path, group_name + '.rules'
    File.open file, 'w' do |f|
      f.write rules.map { |rule| rule + "\n" }.join
    end
  end

  # Removes a group of udev rules.
  def self.remove_rules(group_name)
    file = File.join rules_path, group_name + '.rules'
    File.unlink file if File.exist?(file)
  end
  
  # Asks udev to reload its rules to reflect updates done by add_rules.
  #
  # Returns a false value for success, or a string containing error output if
  # something goes wrong.
  def self.reload_rules
    output = `/etc/init.d/udev restart 2>&1`
    $CHILD_STATUS.to_i == 0 ? nil : output
  end
  
  # Directory or file containing the udev rules.
  def self.rules_path
    if File.exist? '/etc/udev/rules.d'
      return '/etc/udev/rules.d'
    else
      raise "Unsupported OS or distribution."
    end
  end
end  # module Xilinx::Provision::Udev

end  # module Xilinx::Provision

end  # module Xilinx
