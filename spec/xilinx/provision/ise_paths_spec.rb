require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe Xilinx::Provision::IsePaths do
  describe 'impact_path' do
    let(:path) { Xilinx::Provision::IsePaths.impact_path }
    
    it 'is a non-empty string' do
      path.should be_kind_of String
      path.should_not be_empty
    end
    
    it 'can be executed, and outputs a Xilinx banner' do
      Kernel.`(path + ' -help').should include('Xilinx')
    end
  end
end
