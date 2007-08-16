class CreateZubehoer < ActiveRecord::Migration
  
  class Zubehoer < ActiveRecord::Base
  end
  class Reservation < ActiveRecord::Base
  end
  
  def self.up
    # Tabelle fuer separate Zubehoer-Eintraege generieren
    create_table :zubehoer, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.column :lock_version, :integer, :default => 0, :null => false
      t.column :updated_at, :timestamp, :null => false
      t.column :created_at, :timestamp, :default => '2004-01-01 10:10:10', :null => false
      t.column :reservation_id, :integer, :null => false
      t.column :beschreibung, :string, :null => false
      t.column :anzahl, :integer, :default => 1, :null => false
    end
    add_index :zubehoer, :reservation_id
    
    # Zubehoer-Eintraege aus bisherigen Reservationen in diese Tabelle schreiben
    @reservations = Reservation.find( :all, :conditions => 'zubehoer IS NOT NULL' )
    for reservation in @reservations
      @zubehoer = Zubehoer.new( { :updated_at => reservation.updated_at,
            :created_at => reservation.created_at,
            :reservation_id => reservation.id,
            :beschreibung => reservation.zubehoer } )
      @zubehoer.save
    end
    
    # Zubehoer Feld in Reservation loeschen
    remove_column :reservations, :zubehoer
  end

  def self.down
    # Zubehoer Feld in Reservation wieder anlegen
    add_column :reservations, :zubehoer, :text
    
    # Zubehoer-Eintraege aus Tabelle in die Reservation zurueck schreiben
    @zubehoer = Zubehoer.find( :all )
    for zubehoer in @zubehoer
      @reservation = Reservation.find( zubehoer.reservation_id )
      @reservation.zubehoer = zubehoer.beschreibung
      @reservation.save
    end

    # Tabelle fuer separate Zubehoer-Eintraege loeschen
    remove_index :zubehoer, :reservation_id
    drop_table :zubehoer
  end
end
