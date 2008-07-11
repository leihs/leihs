require File.dirname(__FILE__) + "/../spec_helper"
require File.dirname(__FILE__) + '/../app'

describe Event do

  describe "> invitations" do

    before do
      @barcamp = Event.create!(:name => 'Barcamp')
      @janick = Invitee.create!(:name => 'Janick Gers')
      @dave = Invitee.create!(:name => 'Dave Murray')
      @invitation = @barcamp.invitations.create!(:invitee => @janick)
      @barcamp.reload
    end

    it "should be able to create" do
      @barcamp.invitations.should have(1).record
      @barcamp.invitations.first.should == @invitation
      @barcamp.invitations.first.invitee.should == @janick
    end

    it "should be able to delete" do
      @barcamp.invitations.delete(@invitation)
      @barcamp.reload
      @barcamp.invitations.should have(0).records
    end

    it "should be able to <<" do
      @barcamp.invitations << new_invitation = Invitation.create!(:invitee => @janick)
      @barcamp.reload
      @barcamp.should have(2).invitations
      @barcamp.invitations.should include(new_invitation)
    end
    
    it "should be able to find invitations" do
      @barcamp.invitations.should include(@invitation)
    end

    describe " > invitees" do
      it "should be able to create" do
        @steve = @barcamp.invitees.create!(:name => 'Steve Harris')
        @barcamp.reload
        @barcamp.should have(2).invitees
        @barcamp.invitees.should include(@steve)
      end

      it "should be able to delete" do
        @barcamp.invitees.delete(@janick)
        @barcamp.reload
        @barcamp.invitees.should have(0).records
        @barcamp.invitees.should_not include(@janick)
      end

      it "should be able to <<" do
        @barcamp.invitees << @dave
        @barcamp.reload
        @barcamp.should have(2).invitations
        @barcamp.invitees.should include(@dave)
      end

      it "should be able to find invitees" do
        @barcamp.invitees.should include(@janick)
      end

      describe "> tribes" do
        before do
          @adrain = @barcamp.invitees.create!(:name => "Adrain Smith", :tribe => Tribe.create!(:name => "Clansman's tribe"))
          @clansmans_tribe = @adrain.tribe
          @barcamp.reload
        end

        it "should be able to create" do
          @atlantis = @barcamp.tribes.create!(:name => 'Atlantis')
          @barcamp.reload
          @barcamp.should have(2).tribes
          @barcamp.tribes.should include(@atlantis)
        end

        it "should be able to delete" do
          @barcamp.tribes.delete(@clansmans_tribe)
          @barcamp.reload
          @barcamp.tribes.should have(0).records
          @barcamp.invitees.should_not include(@adrain)
        end

        it "should be able to <<" do
          @guitaring_tribe = Tribe.create!(:name => 'Superb guitarists')
          @barcamp.tribes << @guitaring_tribe
          @barcamp.reload
          @barcamp.should have(2).tribes
          @barcamp.tribes.should include(@guitaring_tribe)
        end

        it "should be able to find invitees" do
          @barcamp.tribes.should include(@clansmans_tribe)
        end
      end
    end

    describe "> attendees" do
      before do
        @nicko = Invitee.create!(:name => "Nicko Mc'Brain")
        @barcamp.invitations.create!(:invitee => @nicko, :attending => true)
        @barcamp.reload
      end

      it "should be able to create" do
        @bruce = @barcamp.attendees.create!(:name => 'Bruce Dickinson')
        @barcamp.reload
        @barcamp.attendees.should include(@bruce)
        @barcamp.invitees.should include(@bruce)
        @barcamp.should have(3).invitees
        @barcamp.should have(2).attendees
        #at least one attending should be true
        eval(@barcamp.invitations.collect(&:attending).compact.join(" || ")).should == true
      end

      it "should be able to delete" do
        @barcamp.attendees.delete(@nicko)
        @barcamp.reload
        @barcamp.attendees.should have(0).records
        @barcamp.invitees.should have(1).records
        @barcamp.invitees.should_not include(@nicko)
      end

      it "should be able to <<" do
        @barcamp.attendees << @dave
        @barcamp.reload
        @barcamp.should have(2).attendees
        @barcamp.attendees.should include(@dave)
      end

      it "should be able to find invitations" do
        @barcamp.attendees.should include(@nicko)
        @barcamp.invitees.should include(@nicko)
      end
    end
  end
end
