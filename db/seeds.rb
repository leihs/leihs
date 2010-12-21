require( RAILS_ROOT + '/lib/factory.rb')
Factory.create_default_languages
Factory.create_default_authentication_systems
Factory.create_default_roles
superuser = Factory.create_super_user
puts _("The administrator %{a} has been created ") % { :a => superuser.login }
Factory.create_default_building
