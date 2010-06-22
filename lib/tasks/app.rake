namespace :app do

  desc "Build Railroad diagrams (requires peterhoeg-railroad 0.5.8 gem)"
  task :railroad do
    `railroad -iv -o doc/diagrams/railroad/controllers.dot -C`
    `railroad -iv -o doc/diagrams/railroad/models.dot -M`
  end

# TODO
#  namespace :db do
#    desc "Dump entire database (Structure and Data)"
#    task :dump do
#    end
#  end
  
end