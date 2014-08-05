# encoding: utf-8
require 'spec_helper.rb'
require "#{Rails.root}/features/support/leihs_factory.rb"

describe Authenticator::HsluAuthenticationController, type: :request do

  before(:all) do
#    pending # hslu ldap controller conflicts with required pre and last name
    
    FactoryGirl.create(:inventory_pool)
    LeihsFactory.create_default_languages
    @group = FactoryGirl.create(:group, :name => 'Video')

    Setting::LDAP_CONFIG = File.join(Rails.root, "spec", "LDAP_hslu.yml")
    #LDAP_CONFIG = {"test"=>
    #              {"master_bind_pw"=>"12345",
    #               "base_dn"=>"OU=p_user,OU=prod,OU=hslu,DC=campus,DC=intern",
    #               "encryption"=>"simple_tls",
    #               "master_bind_dn"=> "CN=blah,OU=diblah,OU=diblahblah,OU=hslu,OU=enterprise,DC=campus,DC=intern",
    #               "admin_dn"=> "CN=blah,OU=diblah,OU=diblahblah,OU=p_ma,OU=p_group,OU=prod,OU=hslu,DC=campus,DC=intern",
    #               "port"=>636,
    #               "unique_id_field"=>"pager",
    #               "log_file"=>"log/ldap_server.log",
    #               "video_displayname"=>"DK.BA_VID",
    #               "host"=>"ldap.host",
    #               "search_field"=>"samaccountname",
    #               "log_level"=>"warn"}}
  end

  def destroy_user(login)
    user = User.where(:login => login).first
    if user
      return user.destroy
    end
  end

  before(:each) do

    destroy_user("normal_user")
    destroy_user("video_user")
    destroy_user("numeric_unique_id_user")

    # So we can overwrite the @myhash of LDAP entries and construct a hash of Net::LDAP::Entry just
    # like the real Net::LDAP would
    class Net::LDAP::Entry
      attr_accessor :myhash
    end

    normal_user_hash = {:samaccountname=>["normal_user"],
                        :whenchanged=>["20130402061617.0Z"],
                        :mail=>["testbenutzer@doesnot.exist"],
                        :lastlogontimestamp=>["130093569778872747"],
                        :pwdlastset=>["130080675766612153"],
                        :department=>["Test & Integration"],
                        :telephonenumber=>["041 999 99 99"],
                        :samaccounttype=>["805306368"],
                        :codepage=>["0"],
                        :displayname=>["Test Benutzer testuser"],
                        :primarygroupid=>["513"],
                        :company=>["Hochschule Test"],
                        :givenname=>["Test"],
                        :userprincipalname=>["testuser@campus.intern"],
                        :countrycode=>["756"],
                        :usncreated=>["75556046"],
                        :sn=>["Benutzer"],
                        :dn=>
                      ["CN=Test Benutzer testuser,OU=ma_nopol,OU=p_ma,OU=p_user,OU=prod,OU=hslu,DC=campus,DC=intern"],
                        :objectsid=>
                      ["BINARY DATA HERE"],
                        :streetaddress=>["Musterstrasse 1, Postfach 999"],
                        :distinguishedname=>
                      ["CN=Test Benutzer testuser,OU=ma_nopol,OU=p_ma,OU=p_user,OU=prod,OU=hslu,DC=campus,DC=intern"],
                        :title=>["ICT-Test-Benutzer"],
                        :cn=>["Test Benutzer testuser"],
                        :ipphone=>["9999"],
                        :badpasswordtime=>["0"],
                        :memberof=>
                      ["CN=u_all_ad_deny,OU=p_administration,OU=p_group,OU=prod,OU=hslu,DC=campus,DC=intern"],
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
                        :name=>["Test Benutzer testuser"],
                        :usnchanged=>["77641778"],
                        :postalcode=>["9999"],
                        :logoncount=>["0"],
                        :useraccountcontrol=>["66048"],
                        :whencreated=>["20130318080616.0Z"],
                        :description=>["Testuser für Leihs / vor 18.3.2013"],
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

    video_user_hash = {:samaccountname=>["video_user"],
                        :mail=>["testbenutzer@doesnot.exist"],
                        :department=>["Test & Integration"],
                        :telephonenumber=>["041 999 99 99"],
                        :samaccounttype=>["805306368"],
                        :codepage=>["0"],
                        :displayname=>["DK.BA_VID"],
                        :primarygroupid=>["513"],
                        :company=>["Hochschule Test"],
                        :givenname=>["Test"],
                        :userprincipalname=>["testuser@campus.intern"],
                        :sn=>["Benutzer"],
                        :dn=>
                      ["CN=Test Benutzer testuser,OU=ma_nopol,OU=p_ma,OU=p_user,OU=prod,OU=hslu,DC=campus,DC=intern"],
                        :objectsid=>
                      ["BINARY DATA HERE"],
                        :streetaddress=>["Musterstrasse 1, Postfach 999"],
                        :distinguishedname=>
                      ["CN=Test Benutzer testuser,OU=ma_nopol,OU=p_ma,OU=p_user,OU=prod,OU=hslu,DC=campus,DC=intern"],
                        :title=>["ICT-Test-Benutzer"],
                        :cn=>["Test Benutzer testuser"],
                        :ipphone=>["9999"],
                        :memberof=>
                      ["CN=u_all_ad_deny,OU=p_administration,OU=p_group,OU=prod,OU=hslu,DC=campus,DC=intern"],
                        :l=>["Musterstadt"],
                        :objectclass=>["top", "person", "organizationalPerson", "user"],
                        :st=>["Luzern"],
                        :c=>["CH"],
                        :objectcategory=>
                      ["CN=Person,CN=Schema,CN=Configuration,DC=campus,DC=intern"],
                        :name=>["Test Benutzer testuser"],
                        :postalcode=>["9999"],
                        :pager=>["L2345"],
                        :co=>["Switzerland"]
                        }

    video_user_entry = Net::LDAP::Entry.new
    video_user_entry.myhash = video_user_hash
    video_user_result = [
      video_user_entry
    ]

    numeric_unique_id_user_hash = {:samaccountname=>["numeric_unique_id_user"],
                        :mail=>["testbenutzer@doesnot.exist"],
                        :department=>["Test & Integration"],
                        :telephonenumber=>["041 999 99 99"],
                        :displayname=>["DK.BA_VID"],
                        :primarygroupid=>["513"],
                        :company=>["Hochschule Test"],
                        :givenname=>["Test"],
                        :userprincipalname=>["testuser@campus.intern"],
                        :countrycode=>["756"],
                        :sn=>["Benutzer"],
                        :dn=>
                      ["CN=Test Benutzer testuser,OU=ma_nopol,OU=p_ma,OU=p_user,OU=prod,OU=hslu,DC=campus,DC=intern"],
                        :objectsid=>
                      ["BINARY DATA HERE"],
                        :streetaddress=>["Musterstrasse 1, Postfach 999"],
                        :distinguishedname=>
                      ["CN=Test Benutzer testuser,OU=ma_nopol,OU=p_ma,OU=p_user,OU=prod,OU=hslu,DC=campus,DC=intern"],
                        :title=>["ICT-Test-Benutzer"],
                        :cn=>["Test Benutzer testuser"],
                        :ipphone=>["9999"],
                        :badpasswordtime=>["0"],
                        :memberof=>
                      ["CN=u_all_ad_deny,OU=p_administration,OU=p_group,OU=prod,OU=hslu,DC=campus,DC=intern"],
                        :l=>["Musterstadt"],
                        :objectclass=>["top", "person", "organizationalPerson", "user"],
                        :instancetype=>["4"],
                        :st=>["Luzern"],
                        :c=>["CH"],
                        :objectcategory=>
                      ["CN=Person,CN=Schema,CN=Configuration,DC=campus,DC=intern"],
                        :lastlogoff=>["0"],
                        :name=>["Test Benutzer testuser"],
                        :postalcode=>["9999"],
                        :logoncount=>["0"],
                        :description=>["Testuser für Leihs / vor 18.3.2013"],
                        :pager=>["1234"],
                        :co=>["Switzerland"]
                        }

    numeric_unique_id_user_entry = Net::LDAP::Entry.new
    numeric_unique_id_user_entry.myhash = numeric_unique_id_user_hash
    numeric_unique_id_user_result = [
      numeric_unique_id_user_entry
    ]



    admin_user_hash = {:samaccountname=>["admin_user"],
                        :mail=>["testbenutzer@doesnot.exist"],
                        :department=>["Test & Integration"],
                        :telephonenumber=>["041 999 99 99"],
                        :samaccounttype=>["805306368"],
                        :codepage=>["0"],
                        :displayname=>["DK.BA_VID"],
                        :primarygroupid=>["513"],
                        :company=>["Hochschule Test"],
                        :givenname=>["Test"],
                        :userprincipalname=>["testuser@campus.intern"],
                        :sn=>["Benutzer"],
                        :dn=>
                      ["CN=Test Benutzer testuser,OU=ma_nopol,OU=p_ma,OU=p_user,OU=prod,OU=hslu,DC=campus,DC=intern"],
                        :objectsid=>
                      ["BINARY DATA HERE"],
                        :streetaddress=>["Musterstrasse 1, Postfach 999"],
                        :distinguishedname=>
                      ["CN=Test Benutzer testuser,OU=ma_nopol,OU=p_ma,OU=p_user,OU=prod,OU=hslu,DC=campus,DC=intern"],
                        :title=>["ICT-Test-Benutzer"],
                        :cn=>["Test Benutzer testuser"],
                        :ipphone=>["9999"],
                        :memberof=>
                      ["CN=u_all_ad_deny,OU=p_administration,OU=p_group,OU=prod,OU=hslu,DC=campus,DC=intern", "CN=blah,OU=diblah,OU=diblahblah,OU=p_ma,OU=p_group,OU=prod,OU=hslu,DC=campus,DC=intern"],
                        :l=>["Musterstadt"],
                        :objectclass=>["top", "person", "organizationalPerson", "user"],
                        :st=>["Luzern"],
                        :c=>["CH"],
                        :objectcategory=>
                      ["CN=Person,CN=Schema,CN=Configuration,DC=campus,DC=intern"],
                        :name=>["Test Benutzer testuser"],
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
    allow(mocked_ldap).to receive(:bind).with(any_args).and_return(true)
    allow(mocked_ldap).to receive(:search).with({:base => anything, :filter => Net::LDAP::Filter.eq("samaccountname", "normal_user")}).and_return(normal_user_result)
    allow(mocked_ldap).to receive(:search).with({:base => anything, :filter => Net::LDAP::Filter.eq("samaccountname", "video_user")}).and_return(video_user_result)
    allow(mocked_ldap).to receive(:search).with({:base => anything, :filter => Net::LDAP::Filter.eq("samaccountname", "numeric_unique_id_user")}).and_return(numeric_unique_id_user_result)
    allow(mocked_ldap).to receive(:search).with({:base => anything, :filter => Net::LDAP::Filter.eq("samaccountname", "admin_user")}).and_return(admin_user_result)

    allow(Net::LDAP).to receive(:new) {
      mocked_ldap
    }


  end

  context "if the user does not yet exist" do
    it "should be able to create a normal with various useful data grabbed from LDAP" do
      post 'authenticator/hslu/login', {:login => { :username => "normal_user", :password => "1234" }}, {}
      expect(User.where(:login => "normal_user").first).not_to eq nil
    end
  end

  context "when dealing with users for the Video group" do
    it "should assign users to the group if they have the right displayName" do
      post 'authenticator/hslu/login', {:login => { :username => "video_user", :password => "1234" }}, {}
      user = User.where(:login => "video_user" ).first
      expect(user).not_to eq nil
      expect(user.groups.include?(Group.where(:name => "Video").first)).to be true
    end
    it "should not assign users to the group if they don't have the right displayName" do
      post 'authenticator/hslu/login', {:login => { :username => "normal_user", :password => "1234" }}, {}
      user = User.where(:login => "normal_user").first
      expect(user).not_to eq nil
      expect(user.groups.include?(Group.where(:name => "Video").first)).to be false
    end
  end

  context "if the user is in the admin DN on LDAP" do
    it "should give that user the admin role" do
      post 'authenticator/hslu/login', {:login => { :username => "admin_user", :password => "1234" }}, {}
      user = User.where(:login => "admin_user").first
      expect(user.access_rights.active.collect(&:role).include?(:admin)).to be true
    end
  end
  
  context "when copying the LDAP user's unique_id to the leihs user's badge_id" do
    it "should just use the unique_id as it is in most cases" do
      post 'authenticator/hslu/login', {:login => { :username => "normal_user", :password => "1234" }}, {}
      user = User.where(:login => "normal_user").first
      user.reload
      expect(user).not_to eq nil
      expect(user.badge_id).to eq "L9999"
    end
  end

  context "when the user has a unique_id that is completely numeric" do
    it "should append an 'L' to the start of the user's unique_id and use that instead" do 
      post 'authenticator/hslu/login', {:login => { :username => "numeric_unique_id_user", :password => "1234" }}, {}
      user = User.where(:login => "numeric_unique_id_user").first
      user.reload
      expect(user).not_to eq nil
      expect(user.badge_id).to eq "L1234"
    end
  end

end
