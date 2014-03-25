# encoding: utf-8
require 'spec_helper.rb'
require "#{Rails.root}/features/support/leihs_factory.rb"

describe Authenticator::LdapAuthenticationController do

  before(:all) do
    @ip = FactoryGirl.create(:inventory_pool)
    LeihsFactory.create_default_languages
    Setting::LDAP_CONFIG = File.join(Rails.root, "spec", "LDAP_generic.yml")
  end

  def destroy_user(login)
    user = User.where(:login => login).first
    if user
      return user.destroy
    end
  end

  before(:each) do

    destroy_user("normal_user")

    # So we can overwrite the @myhash of LDAP entries and construct a hash of Net::LDAP::Entry just
    # like the real Net::LDAP would
    class Net::LDAP::Entry
      attr_accessor :myhash
    end

    # NOTE: What a freaking pain in the ass to mock all this.
    # Refactor to use ladle: https://github.com/NUBIC/ladle

    normal_user_hash = {:samaccountname=>["normal_user"],
                        :whenchanged=>["20130402061617.0Z"],
                        :mail=>["test@mail.example.org"],
                        :lastlogontimestamp=>["130093569778872747"],
                        :pwdlastset=>["130080675766612153"],
                        :department=>["Test & Integration"],
                        :telephonenumber=>["044 999 99 99"],
                        :samaccounttype=>["805306368"],
                        :codepage=>["0"],
                        :displayname=>["Test User"],
                        :primarygroupid=>["513"],
                        :company=>["University of Test"],
                        :givenname=>["Test"],
                        :userprincipalname=>["testuser@example.org"],
                        :countrycode=>["756"],
                        :usncreated=>["75556046"],
                        :sn=>["Benutzer"],
                        :dn=>
                      ["CN=Testuser,OU=hslu,DC=example,DC=org"],
                        :objectsid=>
                      ["BINARY DATA HERE"],
                        :streetaddress=>["Musterstrasse 1, Postfach 999"],
                        :distinguishedname=>
                      ["CN=Testuser,OU=hslu,DC=example,DC=org"],
                        :title=>["Lord of Test"],
                        :cn=>["Test User"],
                        :ipphone=>["9999"],
                        :badpasswordtime=>["0"],
                        :memberof=>
                      ["CN=u_all_ad_deny,OU=p_administration,OU=p_group,OU=prod,DC=example,DC=org"],
                        :l=>["Musterstadt"],
                        :objectclass=>["top", "person", "organizationalPerson", "user"],
                        :accountexpires=>["130171032000000000"],
                        :objectguid=>["BINARY DATA HERE"],
                        :instancetype=>["4"],
                        :st=>["Luzern"],
                        :c=>["CH"],
                        :objectcategory=>
                      ["CN=Person,CN=Schema,CN=Configuration,DC=campus,DC=intern"],
                        :lastlogoff=>["0"],
                        :name=>["Test User"],
                        :usnchanged=>["77641778"],
                        :postalcode=>["9999"],
                        :logoncount=>["0"],
                        :useraccountcontrol=>["66048"],
                        :whencreated=>["20130318080616.0Z"],
                        :description=>["Test User for leihs"],
                        :pager=>["L9999"],
                        :dscorepropagationdata=>["16010101000000.0Z"],
                        :lastlogon=>["0"],
                        :co=>["Switzerland"],
                        :physicaldeliveryofficename=>["999"]}

    normal_user_entry = Net::LDAP::Entry.new
    normal_user_entry.myhash = normal_user_hash
    normal_user_result = [
      normal_user_entry
    ]


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

    admin_user_entry = Net::LDAP::Entry.new
    admin_user_entry.myhash = admin_user_hash
    admin_user_result = [
      admin_user_entry
    ]



    mocked_ldap = double("mocked_ldap")
    mocked_ldap.stub(:bind).with(any_args()).and_return(true)
    mocked_ldap.stub(:search).with({:base => anything(), :filter => Net::LDAP::Filter.eq("samaccountname", "normal_user")}).and_return(normal_user_result)
    mocked_ldap.stub(:search).with({:base => anything(), :filter => Net::LDAP::Filter.eq("samaccountname", "admin_user")}).and_return(admin_user_result)

    Net::LDAP.stub(:new) { 
      mocked_ldap
    }


  end

  context "if the user does not yet exist" do
    it "should be able to create a normal with various useful data grabbed from LDAP" do
      post :login, {:login => { :username => "normal_user", :password => "1234" }}, {}
      User.where(:login => "normal_user").first.should_not == nil
      # TODO: Check that all the data from LDAP made it into our user object
    end
  end

  context "if the user is in the admin DN on LDAP" do
    it "should give that user the admin role" do
      post :login, {:login => { :username => "admin_user", :password => "1234" }}, {}
      user = User.where(:login => "admin_user").first
      user.access_rights.active.collect(&:role).include?(:admin).should == true
    end
  end

end
