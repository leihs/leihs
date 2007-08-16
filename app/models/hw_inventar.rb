class HwInventar < ActiveRecord::Base
	
	set_table_name 'hwInventar'
	set_primary_key 'Inv_Serienr'
	
end

HwInventar.establish_connection(
		:adapter => 'mysql',
		:host => '195.176.254.22',
		:database => 'help',
		:encoding => 'utf8',
		:username => 'magnus',
		:password => '2read.0nly!' )
		