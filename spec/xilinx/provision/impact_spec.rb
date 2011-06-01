require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe Xilinx::Provision::Impact do
  describe 'binary_path' do
    let(:path) { Xilinx::Provision::Impact.binary_path }
    
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
      Xilinx::Provision::Impact.stub(:binary_path).and_return('/path/to/impact')
      Kernel.should_receive(:`).
             with('/path/to/impact -mode bscan -port auto -batch impact_batch')
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
end
