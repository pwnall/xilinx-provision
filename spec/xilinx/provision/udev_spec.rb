require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe Xilinx::Provision::Impact do
  let(:path) { Xilinx::Provision::Udev.rules_path }
  
  describe 'rules_path' do
    it 'should point to a directory' do
      File.directory?(path).should be_true
    end
  end
  
  describe 'add_rules' do
    before { Xilinx::Provision::Udev.add_rules ['ab', 'cd'], '99-spec-group' }
    after { Xilinx::Provision::Udev.remove_rules '99-spec-group' }
    
    let(:file_matches) { Dir[File.join(path, '99-spec-group*')] }
    
    it 'should create a file' do
      file_matches.should have(1).file
    end
    
    it 'should write the rules in the file' do
      File.read(file_matches.first).should == "ab\ncd\n"
    end

    describe 'remove_rules' do
      before { Xilinx::Provision::Udev.remove_rules '99-spec-group' }
      
      it 'should remove the previously added file' do
        Dir[File.join(path, '99-spec-group*')].should be_empty
      end
    end
  end
  
  describe 'reload_rules' do
    it 'should execute happily' do
      Xilinx::Provision::Udev.reload_rules
      $CHILD_STATUS.to_i.should == 0
    end
  end
end
