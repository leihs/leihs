Given "a minimal leihs setup" do

  # this is hardcore to see why one test fails when run with the other tests
  # but not when run on its own. For some reason resetting the world before this
  # test makes it behave normally again.
  puts `rake leihs:reset`
  
  Factory.create_default_languages
  Factory.create_default_authentication_system
  Factory.create_default_roles
  Factory.create_super_user
  Factory.create_default_building
end