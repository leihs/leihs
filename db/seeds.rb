require "#{Rails.root}/features/support/leihs_factory.rb"

LeihsFactory.create_default_languages
LeihsFactory.create_default_authentication_systems

main_building = Building.new(:name => "Main building", :code => "ZZZ")
main_building.save

admin = User.where(:login => 'admin').first
unless admin
  admin = User.new(:email => "admin@example.com",
                      :login => "admin",
                      :language_id => Language.default_language.id,
                      :firstname => "Admin",
                      :lastname => "Admin",
                      :authentication_system => AuthenticationSystem.default_system.first)

  admin.save

  dba = DatabaseAuthentication.create(:login => "admin",
                                      :password => "password",
                                      :password_confirmation => "password")
  dba.user = admin

  admin.access_rights.create(:role => :admin)
  if dba.save
    puts "The administrator user 'admin' has been created with password 'password'"
  else
    puts "There was an error creating the login credentials for the default admin user 'admin'. The error was: #{dba.errors.full_messages}"
  end
end
