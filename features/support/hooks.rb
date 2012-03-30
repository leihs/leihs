Before do
  Persona.create_all
  DatabaseCleaner.start
end

After do |scenario|
  DatabaseCleaner.clean
end