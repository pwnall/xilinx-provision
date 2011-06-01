require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe Xilinx::Provision::CableFirmware do
  describe 'rules_path' do
    describe 'on the real system' do
      let(:path) { Xilinx::Provision::CableFirmware.rules_path }
      
      it 'should point to a valid file' do
        File.exist?(path).should be_true
        File.directory?(path).should be_false
      end
    end
    
    describe 'on the mock system' do
      before { Xilinx::Provision::Impact.stub!(:path).and_return(__FILE__) }
      
      it 'should find the mock rules file' do
        Xilinx::Provision::CableFirmware.rules_path.
            should match(/snippet.rules$/)
      end
    end
  end
  
  describe 'udev rules' do
    describe 'on the real system' do
      let(:rules) { Xilinx::Provision::CableFirmware.udev_rules }
      
      it 'should output a non-empty array' do
        rules.should have_at_least(1).rule
      end
      
      it 'should only have strings in the array' do
        rules.all? { |rule| rule.respond_to? :to_str }.should be_true
      end
    end
    
    describe 'on the mock system' do
      before { Xilinx::Provision::Impact.stub!(:path).and_return(__FILE__) }
      
      it 'should match the golden output' do
        Xilinx::Provision::CableFirmware.udev_rules.should == [
          '# version 0003',
          'ATTRS{idVendor}=="03fd", ATTRS{idProduct}=="0008", MODE="666"',
          %Q|SUBSYSTEMS=="usb", ACTION=="add", ATTRS{idVendor}=="03fd", ATTRS{idProduct}=="0007", RUN+="/sbin/fxload -v -t fx2 -I #{File.expand_path('../../../fixtures', __FILE__)}/xusbdfwu.hex -D $tempnode"|
        ]
      end
    end
  end
  
  describe 'configure_udev' do
    it 'should run happily' do
      Xilinx::Provision::CableFirmware.configure_udev.should be_nil
    end
  end
end
