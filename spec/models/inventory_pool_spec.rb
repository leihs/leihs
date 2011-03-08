require 'ruby-debug'
require 'spec/spec_helper.rb'
require RAILS_ROOT + '/lib/factory.rb'

describe InventoryPool do

  context "hand_over_visits" do
    before(:all) do
      Factory.create_default_language
  
      # create default inventory_pool
      @ip = Factory.create_inventory_pool
  
      User.delete_all
      # those should be created inside our default inventory_pool
      Factory.create_user :login => "le_mac"      
      Factory.create_user :login => "eichen_berge"
      Factory.create_user :login => "birke"       
      Factory.create_user :login => "venger"      
      Factory.create_user :login => "hammer"      
      Factory.create_user :login => "siegfried"   
    end
  
    # TODO: see spec_helper -> config.use_transactional_fixtures
    #       this should not be necessary
    before(:each) do
      Contract.delete_all
      ContractLine.delete_all
    end

    it "should return a list of hand_over events per user" do
      n_contract_lines = 3 # arbitrary
      
      open_contracts = User.all.map { |user|
        c = Factory.create_contract( {}, {:contract_lines => n_contract_lines } )
        c.user = user
        c.save
        c
      }
      # make sure no start_date is identical to any other
      previous_date = Date.tomorrow
      open_contracts.map(&:contract_lines).flatten.each do |cl|
       cl.start_date = previous_date  
       cl.end_date   = cl.start_date + 2.days 
       previous_date = previous_date.tomorrow
       cl.save
      end
  
      hand_over_visits = @ip.hand_over_visits()
  
      # We should have as many events as there are different start dates
      hand_over_visits.count.should ==
        open_contracts.map(&:contract_lines).flatten.map(&:start_date).uniq.count
  
      # When we combine all the contract_lines of all the events,
      # then we should get the set of contract_lines that are
      # associated with the users' contracts
      hand_over_visits.map(&:contract_lines).flatten.count.should == 
        open_contracts.map(&:contract_lines).flatten.count
    end

    def start_first_contract_line_on_same_date_as_second( contract )
      contract.instance_eval do
        # these two should now be in the same Event
        contract_lines[0].start_date = contract_lines[1].start_date
        contract_lines[0].end_date = contract_lines[0].start_date + 2.days
        contract_lines[0].save
        save
      end
    end

    def start_third_contract_line_on_different_date( contract )
      contract.instance_eval do
        # just make sure the third contract_line isn't on the same day
        if contract_lines[2].start_date == contract_lines[1].start_date
          contract_lines[2].start_date = contract_lines[1].start_date.tomorrow
          contract_lines[2].end_date = contract_lines[2].start_date + 2.days
          contract_lines[2].save
        end
        save
      end
    end

    it "should return an Event containing contract_lines for items that are reserved from the same day on by a user" do
      open_contract = Factory.create_contract( {}, {:contract_lines => 3 } )
      start_first_contract_line_on_same_date_as_second open_contract
      start_third_contract_line_on_different_date open_contract
      open_contract.instance_eval do
        self.user = User.first
        save
      end
      hand_over_visits = @ip.hand_over_visits()

      # the first two contract_lines should now be grouped inside the first Event, which
      # makes it two events in total
      hand_over_visits.count.should == 2
    end
  
    it "should not mix Events of different users" do
      open_contract = Factory.create_contract( {}, {:contract_lines => 1 } )
      open_contract.user = User.first
      open_contract.save

      open_contract2 = Factory.create_contract( {}, {:contract_lines => 1 } )
      open_contract2.instance_eval {
        self.user = User.last
        contract_lines[0].start_date = open_contract.contract_lines[0].start_date
        contract_lines[0].end_date = contract_lines[0].start_date + 2.days
        contract_lines[0].save
        save
      }

      hand_over_visits = @ip.hand_over_visits()

      # the first two contract_lines should now be grouped inside the first Event, which
      # makes it two events in total
      hand_over_visits.count.should == 2
    end
  end
end

  #  specify "should be invalid without a username" do
  #    @user.email = 'joe@bloggs.com'
  #    @user.should_not_be_valid
  #    @user.errors.on(:username).should_equal "is required"
  #    @user.username = 'someusername'
  #    @user.should_be_valid
  #  end
  #
  #  specify "should be invalid without an email" do
  #    @user.username = 'joebloggs'
  #    @user.should_not_be_valid
  #    @user.errors.on(:email).should_equal "is required"
  #    @user.email = 'joe@bloggs.com'
  #    @user.should_be_valid
  #  end
