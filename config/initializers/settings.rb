if ActiveRecord::Base.connection.tables.include?("settings")

  if Setting.const_defined? :ZONE_ZONE
    Rails.configuration.time_zone = Setting::ZONE_ZONE
  end

end
