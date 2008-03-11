class DatabaseAuthentication 
  
  def initialize(login)
    @account = Account.find_by_login(login)
    @account = Account.new(:login => login) if @account.nil?
  end
  
  def email=(email)
    @account.email = email
    @account.save
  end
  
  def email
    @account.email
  end
  


end