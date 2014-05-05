namespace :app do

  namespace :test do

    desc "Generate personas dumps (executed by CI)"
    task :generate_personas_dumps => :environment do
      Persona.generate_dump

      if execution_id = ENV["DOMINA_EXECUTION_ID"]
        `rm -r /tmp/#{execution_id}`
        `mkdir -p /tmp/#{execution_id}`
        `cp -r #{File.join(Rails.root, "features/personas/dumps/*.sql")} /tmp/#{execution_id}`
      end
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
