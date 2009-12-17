class AddBuildings < ActiveRecord::Migration

  def self.up    
    Building.create :code => "ZO", :name => "Andere Non-ZHDK Addresse"
    Building.create :code => "ZP", :name => "Spuradresse der Benutzer"
    Building.create :code => "ZZ", :name => "Nicht spezifizierte Adresse"
    Building.create :code => "SQ", :name => "Ausstellungsstrasse, 60"
    Building.create :code => "AU", :name => "Ausstellungsstrasse, 100"
    Building.create :code => "MC", :name => "Baslerstrasse, 30 (Mediacampus)"
    Building.create :code => "FH", :name => "Florhofgasse, 6"
    Building.create :code => "FB", :name => "Förrlibuckstrasse"
    Building.create :code => "FR", :name => "Freiestrasse, 56"
    Building.create :code => "GE", :name => "Gessnerallee, 11"
    Building.create :code => "HF", :name => "Hafnerstrasse, 27"
    Building.create :code => "HS", :name => "Hafnerstrasse, 31"
    Building.create :code => "DG", :name => "Hafnerstrasse, 39/41"
    Building.create :code => "HA", :name => "Herostrasse, 5"
    Building.create :code => "HB", :name => "Herostrasse, 10"
    Building.create :code => "HI", :name => "Hirschengraben, 46"
    Building.create :code => "KO", :name => "Limmatstrasse, 57"
    Building.create :code => "LH", :name => "Limmatstrasse, 47"
    Building.create :code => "LI", :name => "Limmatstrasse, 65"
    Building.create :code => "LS", :name => "Limmatstrasse, 45"
    Building.create :code => "MB", :name => "Museum Bellerive"
    Building.create :code => "PF", :name => "Pfingstweidstrasse, 6"
    Building.create :code => "SE", :name => "Seefeldstrasse, 225"
    Building.create :code => "FI", :name => "Sihlquai, 125"
    Building.create :code => "PI", :name => "Sihlquai, 131"
    Building.create :code => "TP", :name => "Technoparkstrasse, 1"
    Building.create :code => "TT", :name => "Tössertobelstrasse, 1"
    Building.create :code => "WA", :name => "Waldmannstrasse, 12"
  end
  
  def self.down
    Building.delete_all
  end
end
