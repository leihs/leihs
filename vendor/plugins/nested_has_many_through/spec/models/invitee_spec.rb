require File.dirname(__FILE__) + "/../spec_helper"
require File.dirname(__FILE__) + '/../app'

describe Invitee do

  describe "> invitations" do

    before do
      @barcamp = Event.create!(:name => 'Barcamp')
      @janick = Invitee.create!(:name => 'Janick Gers')
      @invitation = @barcamp.invitations.create!(:invitee => @janick)
      @barcamp.reload
      @janick.reload
    end

    it "should be able to create" do
      @janick.invitations.should have(1).record
      @janick.invitations.first.should == @invitation
    end

    it "should be able to delete" do
      @janick.invitations.delete(@invitation)
      @janick.reload
      @janick.invitations.should have(0).records
    end

    it "should be able to <<" do
      @janick.invitations << new_invitation = Invitation.create!(:event_associate => EventAssociate.create!(:event => @event))
      @janick.reload
      @janick.should have(2).invitations
      @janick.invitations.should include(new_invitation)
    end

    it "should be able to find invitations" do
      @janick.invitations.should include(@invitation)
    end

    describe " > events" do
      before do
        @dave = Invitee.create!(:name => 'Dave Murray')
        @rio_gig = Event.create!(:name => 'Rock in Rio')
      end

      it "should be able to create" do
        pending("Gotta think if it makes sense to create an anonymous entity in case of an insert for has_one too")
        donington_gig = @dave.events.create!(:name => 'Donington gig')
        @dave.reload
        @dave.should have(1).events
        @dave.events.should include(donington_gig)
      end

      it "should be able to delete" do
        pending("Gotta think if it makes sense to implement this")
        @janick.events.delete(@barcamp)
        @janick.reload
        @janick.events.should have(0).records
      end

      it "should be able to <<" do
        pending("Gotta think if it makes sense to create an anonymous entity in case of an insert for has_one too")
        @dave.events << @barcamp
        @dave.reload
        @dave.should have(1).events
        @dave.invitees.should include(@barcamp)
        @janick.events << @rio_gig
        @janick.reload
        @janick.should have(2).events
        @janick.invitees.should include(@barcamp, @rio_gig)
      end

      it "should be able to find invitees" do
        @janick.events.should include(@barcamp)
      end

      it "should be able to find invitees[for a more complicated case]" do
        @barcamp.invitees << @dave
        @rio_gig.invitees << @dave
        @dave.events.should include(@barcamp, @rio_gig)
        @dave.events.count.should == 2
      end
    end
  end
end
