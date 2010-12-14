#
# create default languages
#
[['Deutsch',   'de_CH'],['English',    'en_US'],
 ['Castellano','es'],   ['Züritüütsch','gsw_CH@zurich']].each do |lang|

  Language.create!(:name => lang[0], :locale_name => lang[1],
                   :default => false, :active => true)
end

german = Language.find :first, :conditions => "name = 'Deutsch'"
german.default = true
german.save
ActiveRecord::Base.connection.change_column_default :users, :language_id, german.id

#
# set up authentication system
#
if AuthenticationSystem.count == 0

  AuthenticationSystem.create!(:name => "Database Authentication",
                               :class_name => "DatabaseAuthentication",
                               :is_active => true, :is_default => true )

  AuthenticationSystem.create!(:name => "LDAP Authentication",
                               :class_name => "LdapAuthentication",
                               :is_default => false)

  AuthenticationSystem.create!(:name => "ZHDK Authentication",
                               :class_name => "Zhdk", :is_default => false)
end

#
# create roles
#
if Role.count == 0
  r_a  = Role.create!(:name => "admin")
  
  r_m = Role.create!(:name => 'manager')
  r_m.move_to_child_of r_a

  r_c = Role.create!(:name => "customer")
  r_c.move_to_child_of r_m
end

#
# create admin
#
if User.count == 0 
  superuser = User.new( :email => "super_user_1@example.com",
                        :login => "super_user_1")

  superuser.unique_id = "super_user_1"
  superuser.save
  admin = Role.find(:first, :conditions => {:name => "admin"})
  
  superuser.access_rights.create!(:role => admin, :inventory_pool => nil)
  puts _("The administrator %{a} has been created ") % { :a => superuser.login }

  d = DatabaseAuthentication.create!(:login => "super_user_1",
				     :password => "pass", :password_confirmation => "pass")
  d.user = superuser
  d.save
end

#
# add buildings
#
[["ZO",  "Andere Non-ZHDK Addresse"],
 ["ZP",  "Heimadresse des Benutzern"],
 ["ZZ",  "Nicht spezifizierte Adresse"],
 ["SQ",  "Ausstellungsstrasse, 60"],
 ["AU",  "Ausstellungsstrasse, 100"],
 ["MC",  "Baslerstrasse, 30 (Mediacampus)"],
 ["FH",  "Florhofgasse, 6"],
 ["FB",  "Förrlibuckstrasse"],
 ["FR",  "Freiestrasse, 56"],
 ["GE",  "Gessnerallee, 11"],
 ["HF",  "Hafnerstrasse, 27"],
 ["HS",  "Hafnerstrasse, 31"],
 ["HA",  "Herostrasse, 5"],
 ["HB",  "Herostrasse, 10"],
 ["HI",  "Hirschengraben, 46"],
 ["KO",  "Limmatstrasse, 57"],
 ["LH",  "Limmatstrasse, 47"],
 ["LI",  "Limmatstrasse, 65"],
 ["LS",  "Limmatstrasse, 45"],
 ["PF",  "Pfingstweidstrasse, 6"],
 ["SE",  "Seefeldstrasse, 225"],
 ["FI",  "Sihlquai, 125"],
 ["PI",  "Sihlquai, 131"],
 ["TP",  "Technoparkstrasse, 1"],
 ["TT",  "Tössertobelstrasse, 1"],
 ["WA",  "Waldmannstrasse, 12"],
 #
 ["DG",  "Hafnerstrasse, 41"],
 ["DI",  "Hafnerstrasse, 39"],
 ["FOE", "Förrlibuckstrasse, 62"],
 ["P5",  "Hardturmstrasse, 11"],
 ["MB",  "Höschgasse 3"],
 ["VE",  "Höschgasse 4"],
 ["MCA", "Baslerstrasse, 30"],
 ["FLG", "Florhofgasse, 6"],
 ["HI1", "Hirschengraben, 1"],
 ["HI20","Hirschengraben, 20"],
 ["HI46","Hirschengraben, 46"],
 ["FRS", "Freiestrasse, 56"],
 ["SFS", "Seefeldstrasse, 225"],
 ["GA9", "Gessnerallee, 9"],
 ["GA11","Gessnerallee, 11"],
 ["GA13","Gessnerallee, 13"],
 ["Z3",  "Militärstrasse, 47"],
 ["FLS", "Florastrasse, 52"],
 ["MES", "Merkurstrasse, 61"],
 ["FLU", "Flurstrasse, 85"],
 ["ARS", "Albisriederstr. 184B"],
 ["TOE", "Tösstobelstrasse, 1"],
 ["RY82","Rychenberg, 82"],
 ["RY94","Rychenberg, 94"],
 ["RY96","Rychenberg, 96-100"],
 ["IFS", "Ifangstrasse, 2"],
 ["BU",  "Schützenmattstrsse, 1B"],
 ["KST", "Kart-Stauffer-Strasse, 26"]].each do |building|

   Building.create! :code => building[0], :name => building[1]
end
