require 'spec_helper'

describe Contract do

  describe "instance methods" do
  
    context "sign" do
      
      it "needs at least one contract line" do
        contract = FactoryGirl.create :contract, :status_const => Contract::UNSIGNED
        contract.lines.size.should == 0
        contract.sign.should be_false
        contract.status_const.should == Contract::UNSIGNED
      end
      
      it "is not possible with an not assigned item line" do
        contract = FactoryGirl.create :contract, :status_const => Contract::UNSIGNED
        contract.lines << FactoryGirl.create(:contract_line, :contract => contract)
        contract.lines.first.item.should be_nil
        contract.sign.should be_false
        contract.status_const.should == Contract::UNSIGNED
      end
    end
  end
end