# coding: UTF-8

# Persona:  Ramon
# Job:      Leihs Developer and Administrator
#
require 'factory'

module Persona
  
  class Ramon
    
    NAME = "Ramon"
    LASTNAME = "C."
    PASSWORD = "password"
    EMAIL = "ramon@zhdk.ch"
    
    def initialize
      ActiveRecord::Base.transaction do 
        create_minimal_setup
        create_admin_user
        create_inventory_pool
      end
    end
    
    def create_admin_user
      @user = Factory(:user, :firstname => NAME, :lastname => LASTNAME, :login => NAME.downcase, :email => EMAIL)
      @user.access_rights.create(:role => Role.find_or_create_by_name("admin"))
      @database_authentication = Factory(:database_authentication, :user => @user, :password => PASSWORD)
    end
    
    def create_minimal_setup
      Factory.create_default_languages
      Factory.create_default_authentication_systems
      Factory.create_default_roles
      Factory.create_default_building
    end
    
    def create_inventory_pool
      description = "EINIGE WICHTIGE HINWEISE:\n\n- Ausleihdauer: max. 1-2 Wochen. Längere Ausleihen nur in Ausnahmefällen und ohne Gewähr!\n\n- Pünktlichkeit: Den anderen zuliebe: Bitte die Ausleihen IMMER am abgemachten Datum zurückbringen; es gibt nichts Schlimmeres als wenn der/die Nächste die bestellten Geräte wegen verspäteter Rückgabe nicht abholen kann.\n\n- Anfragen für Ausleihverlängerungen immer per mail an: ausleihe.pz@zhdk.ch\n\n- Bei Nichtbedarf bitte die Stornierung der gemachten Reservierungen per Mail beantragen; so werden die Geräte wieder für alle verfügbar.\n\n\nÖffnungzeiten:\n\nMontag bis Freitag 8.30 - 9.30 Uhr\nund 12.30 - 16.30 Uhr\n\nZimmer K11 (Untergeschoss)\nim Hauptgebäude\nAustellungsstrasse 60\nCH-8005 Zürich\n\nTelefon: 043 446 44 45\nEmail: ausleihe.pz@zhdk.ch\n\nProduktionszentrum AV-Technik\n  \n"
      contact_details = "AV Verleih  /  ZHdK\nausleihe.pz@zhdk.ch\n+41 43 446 44 45"
      Factory(:inventory_pool, :name => "AV-Ausleihe", :description => description, :contact_details => contact_details, :contract_description => "Audio Visueller Verleih", :email => "ausleihe@zhdk.ch", :shortname => "AVA")
    end

  end  
end
