class InventoryImport::ItHelp < ActiveRecord::Base
  set_table_name 'hwInventar'
  set_primary_key 'Inv_Serienr'


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
  

  