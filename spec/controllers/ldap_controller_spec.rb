# encoding: utf-8
require 'spec_helper.rb'
require "#{Rails.root}/features/support/leihs_factory.rb"

describe Authenticator::LdapAuthenticationController do

  before(:all) do
    ENV['TMPDIR'] = File.join(Rails.root, "tmp")
    # TODO: Move this out to something that runs *before* the test suite itself?
    unless File.exist?(ENV['TMPDIR'])
      Dir.mkdir(ENV['TMPDIR'])
    end
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
    it "should be able to create a normal user with various useful data grabbed from LDAP" do
      post :login, {:login => { :user => "normal_user", :password => "pass" }}, {}
      expect(User.where(:login => "normal_user").first).not_to eq nil
      # TODO: Check that all the data from LDAP made it into our user object
    end
    it "should make sure that users it creates have LDAP as authentication system" do
      post :login, {:login => { :user => "normal_user", :password => "pass" }}, {}
      as = AuthenticationSystem.where(:class_name => "LdapAuthentication").first
      expect(as).not_to eq nil
      expect(User.where(:login => "normal_user").first.authentication_system).to eq as
    end

    it "newly created user should get automatically access as customer in all the pools where automatic access is activated" do
      3.times do
        FactoryGirl.create :inventory_pool
      end
      ips_with_automatic_access = InventoryPool.all.sample(2)
      ips_with_automatic_access.each {|ip| ip.update_attributes automatic_access: true}

      post :login, {:login => { :user => "normal_user", :password => "pass" }}, {}

      user = User.where(:login => "normal_user").first
      access_rights = user.access_rights.where(role: "customer")
      expect(access_rights.count).to eq 2
      ips_with_automatic_access.each {|ip| user.inventory_pools.should include ip}
    end
  end

  context "if the user is in the admin DN on LDAP" do
    it "should give that user the admin role" do
      post :login, {:login => { :user => "admin_user", :password => "pass" }}, {}
      user = User.where(:login => "admin_user").first
      expect(user.access_rights.active.collect(&:role).include?(:admin)).to be true
    end
  end

  context "if the user is not in the admin DN on LDAP" do
    it "should not give that user the admin role" do
      post :login, {:login => { :user => "normal_user", :password => "pass" }}, {}
      user = User.where(:login => "normal_user").first
      expect(user.access_rights.active.collect(&:role).include?(:admin)).to be false
    end
  end

end
