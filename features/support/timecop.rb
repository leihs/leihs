def back_to_the_future(date)
  Timecop.travel(date)
  change_database_current_date
end

def back_to_the_present
  if ENV['TEST_RANDOM_DATE']
    back_to_the_future(Time.parse(ENV['TEST_RANDOM_DATE']))
  else
    Timecop.return
  end
  change_database_current_date
end

def change_database_current_date
  # The minimum representable time is 1901-12-13, and the maximum representable time is 2038-01-19
  ActiveRecord::Base.connection.execute "SET TIMESTAMP=unix_timestamp('#{Time.now.iso8601}')"
  mysql_date = ActiveRecord::Base.connection.exec_query("SELECT CURDATE()").rows.flatten.first
  raise "MySQL current date has not been changed" if mysql_date != Date.today
end
