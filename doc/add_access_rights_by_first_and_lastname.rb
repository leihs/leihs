

require 'faster_csv'
require 'iconv'


# e-mail addresses, one per line, in CSV
names_doz = FasterCSV.read("/tmp/dmu_dozierende-utf8.csv", :col_sep => ';')
names_stud = FasterCSV.read("/tmp/dmu_studenten-utf8.csv", :col_sep => ';')
names_pers = FasterCSV.read("/tmp/dmu_personal-utf8.csv", :col_sep => ';')

name_groups = [names_doz, names_stud, names_pers]

#ic = Iconv.new('ISO-8859-15//TRANSLIT', 'UTF-8')



def process_names(names)
  
  not_unique = 0
  fine = 0
  not_found = 0
  
  names.each do |name|
    
    firstname = name[0]
    lastname = name[1]
  
    users = User.find_all_by_firstname_and_lastname(firstname, lastname)

    if users.count > 1
      puts "++++ WARNING: #{firstname} #{lastname} IS NOT UNIQUE"
      not_unique += 1
    elsif users.count == 1
      puts "#{firstname} #{lastname} is fine"
      fine += 1
    elsif users.nil? or users.count == 0
      puts "#{firstname} #{lastname} was not found"
      not_found += 1
    end
    
    
    
  #   if user
  #    
  #     ar = AccessRight.new
  #     ar.role_id = 3 # Customer
  #     ar.inventory_pool_id = 6 # VIAD
  #     ar.access_level = 1
  #     ar.level = 1
  #     ar.user = user
  #     puts "AccessRight created, do not need to assign to user" if ar.save
  #     
  #     if user.access_rights.include?(ar)
  #       puts "User #{email} already has this access right"
  #     else
  #       user.access_rights << ar
  #       user.save
  #       puts "Access right added for #{email}" if user.save
  #     end
  #   else
  #     puts "User with email #{email} not found"
  #   end

  end
  puts "---------------------------"
  puts "Statistics: #{fine} fine, #{not_unique} not unique, #{not_found} not found"
  puts "---------------------------"
  puts "---------------------------"
end


name_groups.each do |names|
  process_names(names)
end

