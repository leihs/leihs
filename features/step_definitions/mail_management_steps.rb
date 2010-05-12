Given "$name's email address is $email" do |name, email|
  u = User.find_by_login(name)
  u.update_attributes(:email => email)
  u.language = Language.find(2)
  u.save
end

Then "$email receives an email" do |email|
  ActionMailer::Base.deliveries.size.should == 1
  @mail = ActionMailer::Base.deliveries[0]  
  @mail.to[0].should == email
  ActionMailer::Base.deliveries.clear
end

Then "its subject is '$subject'" do |subject|
  @mail.subject.should == subject
end

Then "it contains information '$line'" do |line|
  @mail.body.should match(Regexp.new(line))
end

