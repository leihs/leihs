class SnmInventar < ActiveRecord::Base
	
	set_table_name 'inv'
	#set_primary_key 'id'
	
end

SnmInventar.establish_connection(
		:adapter => 'mysql',
		:host => 'localhost',
		:database => 'snm_inventar',
		:username => 'rubylocal',
		:password => '163ruby9' )