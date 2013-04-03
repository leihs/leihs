require 'spec/spec_helper.rb'
require RAILS_ROOT + '/lib/factory.rb'

describe Authenticator::HsluAuthenticationController do

  before(:all) do
    Factory.create_default_languages
    # create default inventory_pool
    @ip = Factory.create_inventory_pool
  end


  before(:each) do
    normal_user_result = [
      {"streetaddress" => "Foo-Strasse 12",
       "samaccountname" => "normal_user",
       "displayName" => "",
       "memberof" => ["Group_A", "Group_B"],
       "l" => "Luzern",
       "c" => "Switzerland",
       "telephonenumber" => "000 00 00 00",
       "givenname" => "Normal",
       "sn" => "User",
       "unique_id" => "1234"}
    ]


    mocked_ldap = double("mocked_ldap")
    mocked_ldap.stub(:bind).with(any_args()).and_return(true)
    mocked_ldap.stub(:search).with(Net::LDAP::Filter.eq("samaccountname", "normal_user")).and_return(normal_user_result)
    #mocked_ldap.stub(:search).with(Net::LDAP::Filter.eq("samaccountname", "video_user")).and_return(video_user_result)

    Net::LDAP.stub(:new) { 
      mocked_ldap
    }

  end

  it "should assign all the specified attributes to a user after login" do
    lala = Net::LDAP.new
    lala.bind.should == true 
    lala.search(Net::LDAP::Filter.eq("samaccountname", "normal_user")).first["l"].should == "Luzern" 
  end

  it "should be able to create a normal user when logging on" do
    # TODO/WIP
    #post :login, :login => { :user => "normal_user", :password => "1234" }
  end

end
