require 'spec_helper'

describe Visit do

  describe "class methods" do
    context "scopes" do
      it "hand_over are related to unsigned contracts" do
        visits = Visit.hand_over
        visits.all?{|x| x.status_const == Contract::UNSIGNED}.should be_true
        visits.all?{|x| x.lines.all?{|y| y.contract.status_const == Contract::UNSIGNED } }.should be_true
      end
      
      it "hand_over are related to signed contracts" do
        visits = Visit.take_back
        visits.all?{|x| x.status_const == Contract::SIGNED}.should be_true
        visits.all?{|x| x.lines.all?{|y| y.contract.status_const == Contract::SIGNED } }.should be_true
      end
      
      it "should fail" do
        (true == false).should be_false
      end
    end

  end

  describe "instance methods" do

    context "overdue" do
      before :each do
        @visits = Visit.hand_over.where("date < ?", Date.today)
      end

      it "should be overdue" do
        @visits.all?{|x| x.is_overdue }.should be_true
      end
    end

    context "remove line" do
      
      it "is NOT deleting the last line of an SUBMITTED order" do
      end
    end


  end
end