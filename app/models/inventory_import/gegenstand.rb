class InventoryImport::Gegenstand < ActiveRecord::Base

  belongs_to :paket
  belongs_to :kaufvorgang
  
  def kategorie
    if self.attribut_id.nil?
      Category.find_by_name("Andere Hardware")
      #puts "No category found => using 'Andere Hardware'"
    else
      puts "#{self.attribut_id}"
      InventoryImport::Attribut.find(:first, :conditions => ['ding_nr = ? and schluessel = ?', attribut_id, "Kategorie"])
    end
  end
  
end