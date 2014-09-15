namespace :app do

  namespace :test do

    desc "Prepare execution for Cider-CI"
    task :prepare => :environment do
      raise "This task only runs in RAILS_ENV=test !!!" unless Rails.env.test?

      # generate updated cucumber.yml
      `#{File.join(Rails.root, "cider-ci/bin/list_cucumber_tasks.rb")}`

      # generate personas dumps
      Rake::Task["db:drop"].invoke
      Rake::Task["db:create"].invoke
      Rake::Task["db:migrate"].invoke
      require File.join(Rails.root, 'features/support/personas.rb')
      require File.join(Rails.root, 'features/support/timecop.rb')
      Persona.generate_dumps
    end


    desc "Validate Gettext files"
    task :validate_gettext_files do
      `#{Rails.root}/script/validate_gettext_files.sh`
      if $?.exitstatus != 0
        raise "FATAL: Gettext files did not validate. Exiting."
      end
    end
  end
end
