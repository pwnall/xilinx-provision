require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe Xilinx::Provision::CableDriver do
  describe 'build_prerequisites' do
    before do
      # Remove one a package without deps to validate that it reinstalls.
      if File.exist? `which apt-get`.strip
        `apt-get remove -y fxload`
      end
    end
    
    it 'should install the fxload binary' do
      Xilinx::Provision::CableDriver.build_prerequisites.should be_nil
      File.exist?(`which fxload`.strip).should be_true
    end
    
    it 'should forward build output if an error happens' do
      Kernel.stub(:`) do
        Kernel.system 'false'
        'Error 42'
      end
      Xilinx::Provision::CableDriver.build_prerequisites.
          should match(/Error 42/)
    end
  end
  
  describe 'build' do
    before { Xilinx::Provision::CableDriver.build_prerequisites }
    
    before { @temp_dir = Dir.mktmpdir }
    after { FileUtils.rm_rf @temp_dir }
    
    it 'should copy the USB driver to the given target' do
      Xilinx::Provision::CableDriver.build(@temp_dir).should be_nil
      Dir[File.join(@temp_dir, '*.so')].map { |entry| File.basename(entry) }.
                                        should include('libusb-driver.so')
    end
    
    it 'should forward build output if an error happens' do
      Xilinx::Provision::CableDriver.should_receive(:git_url).and_return '::'
      Xilinx::Provision::CableDriver.build(@temp_dir).
          should match(/No such file or directory/i)
    end
  end
  
  describe 'path' do
    let(:path) { Xilinx::Provision::CableDriver.path }
    
    it 'should point to a valid directory' do
      File.exist?(File.dirname(path)).should be_true
      File.directory?(File.dirname(path)).should be_true
    end
  end
end
