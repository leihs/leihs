# desc "Explaining what the task does"
# task :procurement do
#   # Task goes here
# end

namespace :procurement do
  desc 'Procurement data seed'
  task seed: :environment do

    Procurement::Access.admins.create user_id: 1973 # Franco Sellitto

  end
end

