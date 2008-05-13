class User < ActiveRecord::Base

  belongs_to :authentication_system
  has_and_belongs_to_many :roles
  has_many :orders
  has_many :contracts
  has_one :current_contract, :class_name => "Contract", :conditions => ["status_const = ?", Contract::NEW]
  
  acts_as_ferret :fields => [ :login ]  #, :store_class_name => true

  def authinfo
    @authinfo ||= Class.const_get(authentication_system.class_name).new(login)
  end
  
  def email=(email)
    authinfo.email = email
  end
  
  def email
    authinfo.email
  end
  
  def get_current_contract
    c = current_contract
    c ||= Contract.create(:user => self, :status_const => Contract::NEW)
    c
  end
  
  
end
