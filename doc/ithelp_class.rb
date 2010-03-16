class ItHelp < ActiveRecord::Base
  set_table_name 'hwInventar'
  set_primary_key 'Inv_Serienr'

  def self.connect_dev
    establish_connection(
        :adapter => 'mysql',
        :host => '127.0.0.1',
        :database => 'ithelp_dev',
        :encoding => 'latin1',
        :username => 'root',
        :password => 'mysql')
  end
  
  def self.connect_prod
    establish_connection(
      :adapter => 'mysql',
        :host => '195.176.254.49',
        :database => 'ithelp_alt',
        :encoding => 'utf8',
        :username => 'helpread',
        :password => '2read.0nly!')
  end
  
  def to_be_imported
      InventoryImport::ItHelp.find( :all,
          :conditions => "rental like 'yes'",
          :order => 'Inv_Serienr')
  end

  def retired?
   
    if self.Ausmuster_Dat.nil?
      false
    else
      self.Ausmuster_Dat >= Date.new(1970, 1, 1)
    end

  end
  
end
  

