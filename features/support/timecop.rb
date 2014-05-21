def back_to_the_future(datetime)
  mode = ENV['TIMECOP_MODE'] || :travel
  Timecop.send(mode, datetime)
  change_database_current_datetime
end

def back_to_the_present
  if ENV['TEST_DATETIME']
    back_to_the_future(Time.parse(ENV['TEST_DATETIME']))
  else
    Timecop.return
  end
  change_database_current_datetime
end

def change_database_current_datetime
  # The minimum representable time is 1901-12-13, and the maximum representable time is 2038-01-19
  ActiveRecord::Base.connection.execute "SET TIMESTAMP=unix_timestamp('#{Time.now.utc.iso8601}')"
  # FIXME
  # mysql_now = ActiveRecord::Base.connection.exec_query("SELECT NOW()").rows.flatten.first
  # raise "MySQL current datetime has not been changed" if mysql_now != Time.now
end
