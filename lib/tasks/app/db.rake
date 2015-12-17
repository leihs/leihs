namespace :app do
  namespace :db do

    desc('Sync local application instance with test servers ' \
         'most recent database dump')
    task :sync do
      puts `mkdir ./db/backups/`
      # rubocop:disable Metrics/LineLength
      puts `rsync -avuz leihs@test.leihs.zhdk.ch:~/test/leihs-current.sql ./db/backups/`
      # rubocop:enable Metrics/LineLength

      Rake::Task['db:drop'].invoke
      Rake::Task['db:create'].invoke

      puts `mysql -h localhost -u root leihs2_dev < ./db/backups/leihs-current.sql`

      Rake::Task['db:migrate'].invoke
      Rake::Task['leihs:maintenance'].invoke

      # also sync the test database schema
      `RAILS_ENV=test rake db:drop db:create db:migrate`
    end

  end
end
