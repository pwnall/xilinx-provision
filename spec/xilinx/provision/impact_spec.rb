require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe Xilinx::Provision::Impact do
  describe 'path' do
    let(:path) { Xilinx::Provision::Impact.path }
    
    it 'is a non-empty string' do
      path.should be_kind_of String
      path.should_not be_empty
    end
    
    it 'can be executed, and outputs a Xilinx banner' do
      Kernel.`(path + ' -help').should include('Xilinx')
    end
  end
  
  describe 'run' do
    it 'should piece the impact command-line correctly' do
      Xilinx::Provision::Impact.stub(:path).and_return('/path/to/impact')
      Kernel.should_receive(:`).with 'LD_PRELOAD=/path/to/libusb-driver.so ' +
          '/path/to/impact -port auto -mode bscan -batch impact_batch 2>&1'
      lambda {
        Xilinx::Provision::Impact.run :batch => ['identify'], :mode => :bscan,
            :cable_port => :auto
      }.should_not raise_error
    end
    
    it 'should run an identify correctly' do
      Xilinx::Provision::Impact.run(:batch => ['identify'], :mode => :bscan,
          :cable_port => :auto).should match(/identifying chain/i)
    end
  end
  
  describe 'parse_identify' do
    describe 'on mock input' do
      let(:output) do
        Xilinx::Provision::Impact.parse_identify(File.read(
            File.expand_path('../../../fixtures/impact_detect', __FILE__)))
      end
      
      it 'should find 5 devices' do
        output.should have(5).devices
      end
      
      it 'should show the FPGA as device 0' do
        output[0][:name].should == 'Xilinx xc5vlx110t'
      end

      it 'should identify the FPGA version' do
        output[0][:name].should == 'Xilinx xc5vlx110t'
      end
    end
  end
  
  describe 'identify_chain' do
    it 'should find at least one device' do
      Xilinx::Provision::Impact.identify_chain.should have_at_least(1).device
    end
  end
  
  describe 'program_fpga' do
    describe 'with the ethernet bitfile' do
      let(:bitfile) do
        File.expand_path('../../../fixtures/ethernet_ping.bit', __FILE__)
      end
      
      let(:return_value) do
        Xilinx::Provision::Impact.program_fpga bitfile
      end
      
      let(:ethernet_device) do
        'eth0'
      end
      
      it 'should return nil for success' do
        return_value.should be_nil
      end
      
      it 'should make the FPGA respond to pings' do
        client = EtherPing::Client.new ethernet_device, 0x88B5, '001122334455'
        client.ping("abcd", 3).should be_kind_of(Numeric)
      end
    end
  end
end
