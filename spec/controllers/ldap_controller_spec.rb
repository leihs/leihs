# encoding: utf-8
require 'spec_helper.rb'
require "#{Rails.root}/features/support/leihs_factory.rb"

describe Authenticator::LdapAuthenticationController do

  before(:all) do
    @ip = FactoryGirl.create(:inventory_pool)
    LeihsFactory.create_default_languages
    Setting::LDAP_CONFIG = File.join(Rails.root, "spec", "LDAP_generic.yml")

    @server = Ladle::Server.new(
      :port => 12345,
      :ldif => File.join(Rails.root, "spec", "ldif", "generic.ldif"),
      :domain => "dc=example,dc=org"
    )
    @server.start
  end

  after(:all) do
    @server.stop
  end

  def destroy_user(login)
    user = User.where(:login => login).first
    if user
      return user.destroy
    end
  end

  before(:each) do
    destroy_user("normal_user")
  end

  context "if the user does not yet exist" do
    it "should be able to create a normal with various useful data grabbed from LDAP" do
      post :login, {:login => { :username => "normal_user", :password => "pass" }}, {}
      User.where(:login => "normal_user").first.should_not == nil
      # TODO: Check that all the data from LDAP made it into our user object
    end
  end

  context "if the user is in the admin DN on LDAP" do
    it "should give that user the admin role" do
      post :login, {:login => { :username => "admin_user", :password => "pass" }}, {}
      user = User.where(:login => "admin_user").first
      user.access_rights.active.collect(&:role).include?(:admin).should == true
    end
  end

  context "if the user is not in the admin DN on LDAP" do
    it "should not give that user the admin role" do
      post :login, {:login => { :username => "normal_user", :password => "pass" }}, {}
      user = User.where(:login => "normal_user").first
      user.access_rights.active.collect(&:role).include?(:admin).should == false
    end
  end

end
