namespace :app do

  namespace :test do

    desc 'Prepare execution for Cider-CI'
    task prepare: :environment do
      raise 'This task only runs in RAILS_ENV=test !!!' unless Rails.env.test?

      # generate updated cucumber.yml
      system "#{File.join(Rails.root, './.cider-ci/bin/list_cucumber_tasks.rb')}"

      # generate personas sql dumps
      system 'cucumber ' \
             "#{File.join(Rails.root,
                          'features/personas/generating_personas.feature')}"
    end

    desc 'Validate Gettext files'
    task :validate_gettext_files do
      `#{Rails.root}/script/validate_gettext_files.sh`
      if $?.exitstatus != 0
        raise 'FATAL: Gettext files did not validate. Exiting.'
      end
    end
  end
end
