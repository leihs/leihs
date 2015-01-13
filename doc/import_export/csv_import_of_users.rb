
# The CSV file to import needs to be:
# 1. Tab-separated.
# 2. Use " as a quote char.
# 3. Have the headers and fields:
#      GivenName: The first name of the user
#      sn: The surname of the user.
#      mail: The email address of the user.
#      login: The username of the user.  #      password: The desired password. If blank, a random password is used.
#      department: The user's department, gets written to extended_info.
#      Inventory pools: Semicolon-separated list of pools the user needs access to.
#
# Users from the file /tmp/managers.csv will be created with the role "inventory manager"
# Users from the file /tmp/users.csv will be created with the role "customer"

require 'pry'

def create_auth_for_user(user)
  password = SecureRandom.base64(6).tr('+/=lIO0', 'pqrsxyz')
  dba = DatabaseAuthentication.create(:login => user[:login],
                                      :password => password,
                                      :password_confirmation => password)
  dba.user = user
  if dba.save
    @log.puts("DatabaseAuthentication for #{user} created. Password: #{password}")
    @passwords.puts("#{user.login} : #{password}")
  else
    @log.puts("DatabaseAuthentication for #{user} could not be created. #{dba.errors.full_messages}")
  end
end

# Retrieve all pools with matching names. Non-matching ones are simply
# created.
def pools(pools_string)
  inventory_pools = []
  pool_names = pools_string.split(";").map{|string| string.strip}
  pool_names.each do |name|
    inventory_pool = InventoryPool.where(:name => name).first
    if inventory_pool.nil?
      inventory_pool = InventoryPool.create(:name => name,
                                            :shortname => name[0..2].upcase,
                                            :email => 'pool@example.com')
    end
    inventory_pools << inventory_pool
  end
  inventory_pools
end

def give_role(user, role, inventory_pool)
  if user.access_rights.create(:role => role.to_sym, :inventory_pool => inventory_pool)
    @log.puts "Access rights for #{user} to pool #{inventory_pool} as #{role} created."
  else
    @log.puts "ERROR: Access rights for #{user} to pool #{inventory_pool} could not be created."
  end
end


def create_basic_elements(user, options = {})
    role = 'customer'
    role = options[:role] if options[:role]
    create_auth_for_user(user)
    binding.pry if options[:inventory_pools].blank?
    inventory_pools = pools(options[:inventory_pools])
    inventory_pools.each do |ip|
      give_role(user, role, ip)
    end
end

def create_user(options = {})
  user = User.new(:email => options[:email],
                  :login => options[:login],
                  :firstname => options[:firstname],
                  :lastname => options[:lastname],
                  :phone => options[:phone],
                  :authentication_system => AuthenticationSystem.where(:class_name => 'DatabaseAuthentication').first)
  user.extended_info = {}
  user.extended_info['department'] = options[:department]
  user.extended_info['program'] = options[:program]
  if user.save
    @log.puts("Saved user #{user.to_s}")
    create_basic_elements(user, options)
  else
    @log.puts("ERROR: Could not save user #{user.to_s}, #{user.errors.full_messages}")
  end
end

def csv_to_user_options(csv)
  {:email => csv['mail'],
   :login => csv['login'],
   :firstname => csv['GivenName'],
   :lastname => csv['sn'],
   :phone => csv['telephoneNumber'],
   :department => csv['department'],
   :program => csv['Program and year'],
   :inventory_pools => csv['Inventory pools']}
end

@log = File.open("/tmp/user_import.log", "a+")
@passwords = File.open("/tmp/passwords.txt", "a+")

# Import managers
if File.exists?('/tmp/managers.csv')
  @log.puts('---', 'Importing managers from /tmp/managers.csv')
  CSV.open("/tmp/managers.csv", "r", { :col_sep => "\t", :quote_char => "\"", :headers => true}).each do |csv|
    create_user(csv_to_user_options(csv).merge(:role => 'inventory_manager'))
  end
end

if File.exists?('/tmp/customers.csv')
  @log.puts('---', 'Importing customers from /tmp/customers.csv')
  CSV.open("/tmp/customers.csv", "r", { :col_sep => "\t", :quote_char => "\"", :headers => true}).each do |csv|
    create_user(csv_to_user_options(csv))
  end
end

@log.close
@passwords.close
