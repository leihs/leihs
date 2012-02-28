require 'spec_helper'
require Rails.root + 'lib/factory'

describe InventoryPool do

  context "hand_over and take_back visits" do

    before(:all) do
      Factory.create_default_languages
    
      # create default inventory_pool
      @ip = Factory.create_inventory_pool
    
      User.delete_all
      # those should be created inside our default inventory_pool
      Factory.create_user :login => "le_mac"      
      Factory.create_user :login => "eichen_berge"
      Factory.create_user :login => "birke"       
      Factory.create_user :login => "venger"      
      Factory.create_user :login => "siegfried"   
      @manager = \
      Factory.create_user({:login => "hammer"},
                          {:role  => "manager"} )
    end
    

    context "hand_over_visits" do

      # TODO: see spec_helper -> config.use_transactional_fixtures
      #       this should not be necessary
      before(:each) do
        Contract.delete_all
        ContractLine.delete_all
      end


      it "should return a list of hand_over events per user" do

        open_contracts = User.all.map { |user|
          Factory.create_contract( {:user => user},
                                   {:contract_lines => 3 } ) # arbitrary
        }
        make_sure_no_start_date_is_identical_to_any_other! open_contracts
    
        hand_over_visits = @ip.visits.hand_over
        # We should have as many events as there are different start dates
        hand_over_visits.count.should equal(
          open_contracts.flat_map(&:contract_lines).map(&:start_date).uniq.count )
    
        # When we combine all the contract_lines of all the events,
        # then we should get the set of contract_lines that are
        # associated with the users' contracts
        hand_over_visits.flat_map(&:contract_lines).count.
          should equal( open_contracts.flat_map(&:contract_lines).count )
      end


      it "should return an Event containing contract_lines for items that are reserved from the same day on by a user" do
        open_contract = Factory.create_contract( {:user => User.first},
                                                 {:contract_lines => 3 } )
        start_first_contract_line_on_same_date_as_second! open_contract
        start_third_contract_line_on_different_date! open_contract
        hand_over_visits = @ip.visits.hand_over

        # the first two contract_lines should now be grouped inside the
        # first Event, which makes it two events in total
        hand_over_visits.count.should equal(2)
      end
    

      it "should not mix Events of different users" do
        open_contract  = Factory.create_contract( {:user => User.first},
                                                  {:contract_lines => 1 } )

        open_contract2 = Factory.create_contract( {:user => User.last},
                                                  {:contract_lines => 1 } )
        open_contract2.instance_eval {
          contract_lines[0].start_date = open_contract.contract_lines[0].start_date
          contract_lines[0].end_date   = contract_lines[0].start_date + 2.days
          contract_lines[0].save
        }

        hand_over_visits = @ip.visits.hand_over

        # the first two contract_lines should now be grouped inside the
        # first Event, which makes it two events in total
        hand_over_visits.count.should equal(2)
      end

      def start_first_contract_line_on_same_date_as_second!( contract )
        contract.instance_eval do
          # these two should now be in the same Event
          contract_lines[0].start_date = contract_lines[1].start_date
          contract_lines[0].end_date = contract_lines[0].start_date + 2.days
          contract_lines[0].save
          save
        end
      end

      def start_third_contract_line_on_different_date!( contract )
        contract.instance_eval do
          # just make sure the third contract_line isn't on the same day
          if contract_lines[2].start_date == contract_lines[1].start_date
            contract_lines[2].start_date = contract_lines[1].start_date.tomorrow
            contract_lines[2].end_date   = contract_lines[2].start_date + 2.days
            contract_lines[2].save
          end
          save
        end
      end

      def make_sure_no_start_date_is_identical_to_any_other!(open_contracts)
        previous_date = Date.tomorrow
        open_contracts.flat_map(&:contract_lines).each do |cl|
          cl.start_date = previous_date  
          cl.end_date   = cl.start_date + 2.days 
          previous_date = previous_date.tomorrow
          cl.save
        end
      end
    end

    # mostly copy/paste of "hand_over_visits"
    context "take_back_visits" do

      # see above
      before(:each) do
        Contract.delete_all
        ContractLine.delete_all
      end


      it "should return a list of take_back events per user" do

        open_contracts = User.all.map { |user|
          Factory.create_contract( {:user => user},
                                   {:contract_lines => 3 } ) # arbitrary
        }
        make_sure_no_end_date_is_identical_to_any_other! open_contracts

        open_contracts.each { |c| c.sign(c.contract_lines, @manager) }
    
        take_back_visits = @ip.visits.take_back
    
        # We should have as many events as there are different start dates
        take_back_visits.count.should equal(
          open_contracts.flat_map(&:contract_lines).map(&:end_date).uniq.count )
    
        # When we combine all the contract_lines of all the events,
        # then we should get the set of contract_lines that are
        # associated with the users' contracts
        take_back_visits.flat_map(&:contract_lines).count.
          should equal( open_contracts.flat_map(&:contract_lines).count )
      end


      it "should return an Event containing contract_lines for items that are reserved from the same day on by a user" do
        open_contract = Factory.create_contract( {:user => User.first},
                                                 {:contract_lines => 3 } )
        end_first_contract_line_on_same_date_as_second! open_contract
        end_third_contract_line_on_different_date! open_contract

        open_contract.sign(open_contract.contract_lines, @manager)
    
        take_back_visits = @ip.visits.take_back

        # the first two contract_lines should now be grouped inside the
        # first Event, which makes it two events in total
        take_back_visits.count.should equal(2)
      end
    

      it "should not mix Events of different users" do
        open_contract  = Factory.create_contract( {:user => User.first},
                                                  {:contract_lines => 1 } )

        open_contract2 = Factory.create_contract( {:user => User.last},
                                                  {:contract_lines => 1 } )
        open_contract2.instance_eval {
          contract_lines[0].end_date = open_contract.contract_lines[0].end_date
          contract_lines[0].save
        }

        [ open_contract, open_contract2].each { |c| c.sign(c.contract_lines, @manager) }

        take_back_visits = @ip.visits.take_back
    
        # the first two contract_lines should now be grouped inside the
        # first Event, which makes it two events in total
        take_back_visits.count.should equal(2)
      end

      def make_sure_no_end_date_is_identical_to_any_other!(open_contracts)
        last_date = open_contracts.flat_map(&:contract_lines).map(&:end_date).max { |a,b| a <=> b }
        open_contracts.flat_map(&:contract_lines).each do |cl|
          cl.end_date = last_date  
          last_date = cl.end_date.tomorrow
          cl.save
        end
      end

      def end_first_contract_line_on_same_date_as_second!( contract )
        contract.instance_eval do
          # these two should now be in the same Event
          contract_lines[0].end_date = contract_lines[1].end_date
          contract_lines[0].save
          save
        end
      end

      def end_third_contract_line_on_different_date!( contract )
        contract.instance_eval do
          # just make sure the third contract_line isn't on the same day
          if contract_lines[2].end_date == contract_lines[1].end_date
            contract_lines[2].end_date = contract_lines[1].end_date.tomorrow
            contract_lines[2].save
          end
          save
        end
      end

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
