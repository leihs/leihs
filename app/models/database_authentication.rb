class DatabaseAuthentication < ActiveRecord::Base

  attr_accessor :password
  
  validates_presence_of     :login
  validates_presence_of     :password, :password_confirmation
  validates_length_of       :password, :within => 4..40
  validates_confirmation_of :password
  validates_length_of       :login,    :within => 3..255
  validates_uniqueness_of   :login, :case_sensitive => false

  before_validation :encrypt_password
  
  belongs_to :user

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = where(['login = ?', login]).first # need to get the salt
    u and u.authenticated?(password) ? u : nil
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  private

  def encrypt(password)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  def encrypt_password
    return if password == "_password_"
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    self.crypted_password = encrypt(password)
  end

end
