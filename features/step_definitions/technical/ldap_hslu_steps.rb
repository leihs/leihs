require 'cucumber/rspec/doubles'

Given(/^the LDAP\-HSLU authentication system is enabled and configured$/) do
  as = AuthenticationSystem.new(:name => "HsluAuthentication",
                                :class_name => "HsluAuthentication")
  as.is_active = true
  expect(as.save).to be true
  Setting::LDAP_CONFIG = File.join(Rails.root, "features", "data", "LDAP_hslu.yml")
end

Given(/^an LDAP response object for HSLU is mocked$/) do
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

Given(/^a group called "(.*?)" exists$/) do |groupname|
  @group = FactoryGirl.create(:group, :name => groupname)
end

When(/^I log in as HSLU-LDAP user "(.*?)"$/) do |username|
  post 'authenticator/hslu/login', {:login => { :username => username, :password => "1234" }}, {}
end

Then(/^the user "(.*?)" should have HSLU-LDAP as an authentication system$/) do |username|
  as = AuthenticationSystem.where(:class_name => "HsluAuthentication").first
  expect(as).not_to be nil
  expect(User.where(:login => username).first.authentication_system).to eq as
end

Then(/^the user "(.*?)" should have a badge ID of "(.*?)"$/) do |username, badge_id|
  expect(User.where(:login => username).first.badge_id).to eq badge_id
end

