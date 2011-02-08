Given "a minimal leihs setup" do
  Factory.create_default_languages
  Factory.create_default_authentication_system
  Factory.create_default_roles
  Factory.create_super_user
  Factory.create_default_building
end