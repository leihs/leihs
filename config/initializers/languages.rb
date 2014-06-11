if ActiveRecord::Base.connection.tables.include?("languages") and not Rails.env.test?

  unless Language.exists?

    require "#{Rails.root}/features/support/leihs_factory.rb"
    LeihsFactory.create_default_languages

    puts "Languages created: %s" % Language.all.map(&:name).join(', ') if Language.exists?

  end

end




