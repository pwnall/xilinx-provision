require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Xilinx::Provision do
  describe 'fpga' do
    it 'delegates to Impact.program_fpga' do
      Xilinx::Provision::Impact.should_receive(:program_fpga).
                                with('/path/to/bitfile', {}).and_return(nil)
      Xilinx::Provision.fpga('/path/to/bitfile').should be_true
    end
    
    it 'raises an exception if programming fails' do
      Xilinx::Provision::Impact.should_receive(:program_fpga).
                                with('/path/to/bitfile', {}).and_return("42")
      lambda {
        Xilinx::Provision.fpga '/path/to/bitfile'
      }.should raise_error
    end
    
    it 'works with a real bitfile' do
      lambda {
        bitfile = File.expand_path '../../fixtures/ethernet_ping.bit', __FILE__
        Xilinx::Provision.fpga bitfile
      }.should_not raise_error
    end
  end
end
