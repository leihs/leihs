namespace :leihs do
  namespace :dbio do
    desc 'Export the database content into a RDMS independent dump;' \
      ' FILE=tmp/db_data.yml'
    task export: :environment do
      Leihs::DBIO.export ENV['FILE'].presence
    end

    desc 'Restore a legacy personas MySQL dump; DATASET=minimal|normal|huge'
    task restore_lagacy: :environment do
      load 'features/support/dataset.rb'
      Dataset.restore_random_dump(ENV['DATASET'].presence || 'normal')
    end
  end
end
