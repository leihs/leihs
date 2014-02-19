if ActiveRecord::Base.connection.tables.include?("settings")

  if Setting.const_defined? :TIME_ZONE
    Rails.configuration.time_zone = Setting::TIME_ZONE
  end

end
