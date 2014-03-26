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


    admin_user_hash = {:samaccountname=>["admin_user"],
                       :mail=>["testadmin@mail.example.org"],
                        :department=>["IT Administration"],
                        :telephonenumber=>["044 999 99 99"],
                        :samaccounttype=>["805306368"],
                        :codepage=>["0"],
                        :displayname=>["Test Admin"],
                        :primarygroupid=>["513"],
                        :company=>["University of Test"],
                        :givenname=>["Test"],
                        :userprincipalname=>["testuser@campus.intern"],
                        :sn=>["Benutzer"],
                        :dn=>
                      ["CN=Test Admin testadmin,DC=example,DC=org"],
                        :objectsid=>
                      ["BINARY DATA HERE"],
                        :streetaddress=>["Musterstrasse 1, Postfach 999"],
                        :distinguishedname=>
                      ["CN=Test Admin testadmin,DC=example,DC=org"],
                        :title=>["Admin from Hell"],
                        :cn=>["Test Admin"],
                        :ipphone=>["9999"],
                        :memberof=>
                      ["CN=admin,DC=example,DC=org", "CN=golfclub,DC=example,DC=org"],
                        :l=>["Musterstadt"],
                        :objectclass=>["top", "person", "organizationalPerson", "user"],
                        :st=>["Luzern"],
                        :c=>["CH"],
                        :objectcategory=>
                      ["CN=Person,CN=Schema,CN=Configuration,DC=example,DC=org"],
                        :name=>["Test Admin testadmin"],
                        :postalcode=>["9999"],
                        :pager=>["L2345"],
                        :co=>["Switzerland"]
                        }

    #Net::LDAP.stub(:new) { 
    #  mocked_ldap
    #}


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

end
