Given 'a minimal leihs setup' do

  # this is hardcore to see why one test fails when run with the other tests
  # but not when run on its own. For some reason resetting the world before this
  # test makes it behave normally again.
  
  #old?????# puts `rake leihs:reset`
  LeihsFactory.create_default_languages
  LeihsFactory.create_default_authentication_system
  LeihsFactory.create_super_user
  LeihsFactory.create_default_building
end