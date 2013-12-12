



# e-mail addresses, one per line, in CSV
require 'csv'
emails = CSV.read("/tmp/emails.csv")

emails.each do |email|
    
  user = User.find_by_email(email)

  if user
   
    ar = AccessRight.new
    ar.role_id = 3 # Customer
    ar.inventory_pool_id = 6 # VIAD
    ar.access_level = 1
    ar.level = 1
    ar.user = user
    puts "AccessRight created, do not need to assign to user" if ar.save
    
    if user.access_rights.active.include?(ar)
      puts "User #{email} already has this access right"
    else
      user.access_rights << ar
      user.save
      puts "Access right added for #{email}" if user.save
    end
  else
    puts "User with email #{email} not found"
  end

end