module Dataset
  extend self

  def back_to_date(datetime = nil)
    if datetime
      mode = ENV['TIMECOP_MODE'] || :travel
      Timecop.send(mode, datetime)
    else
      if ENV['TEST_DATETIME']
        back_to_date(Time.parse(ENV['TEST_DATETIME']))
      else
        Timecop.return
      end
    end

    # The minimum representable time is 1901-12-13, and the maximum representable time is 2038-01-19
    #tmp# ActiveRecord::Base.connection.execute "SET time_zone='+1:00'"
    ActiveRecord::Base.connection.execute "SET TIMESTAMP=unix_timestamp('#{Time.now.iso8601}')" #old# Time.now.utc.iso8601
    #mysql_now = ActiveRecord::Base.connection.exec_query("NOW()").rows.flatten.first
    #raise "MySQL current datetime has not been changed" if mysql_now != Time.now
    mysql_now = ActiveRecord::Base.connection.exec_query("SELECT CURDATE()").rows.flatten.first
    raise "MySQL current datetime has not been changed" if mysql_now != Date.today
  end

  def restore_random_dump(minimal = false)
    use_test_datetime

    config = Rails.configuration.database_configuration[Rails.env]
    file_name = dump_file_name(minimal)
    cmd = "mysql #{config['host'] ? "-h #{config['host']}" : nil} -u #{config['username']} #{config['password'] ? "--password=#{config['password']}" : nil} #{config['database']} < #{file_name}"

    # we need this variable assignment in order to wait for the end of the system call. DO NOT DELETE !
    dump_restored = system(cmd)
    raise "persona dump not loaded" unless dump_restored

    # ensure the settings are initialized
    Setting.initialize_constants

    dump_restored
  end

  def use_test_datetime(reset: false, freeze: false)
    if freeze
      ENV['TIMECOP_MODE'] = "freeze"
      Timecop.return
    end

    get_test_datetime(reset)

    test_datetime = ENV['TEST_DATETIME'].gsub(/\D/, '').to_i
    srand(test_datetime)

    unless $random
      $random = Random.new(test_datetime)

      # in order to guarantuee the same sample results on CI and locally, we have to change these ruby methods to use the global TEST_DATETIME seed
      Array.class_eval do
        def sample_with_random(*args)
          if args.empty?
            sample_without_random(random: $random)
          elsif args.last.is_a? Hash
            sample_without_random(*args)
          elsif not args.first.is_a? Hash
            sample_without_random(args.first, {random: $random})
          end
        end
        alias_method_chain :sample, :random
      end

      # in order to guarantuee the same sample results on CI and locally, we seed the mysql random function
      Arel::SelectManager.class_eval do
        def order_with_seed(*args)
          if args[0].is_a? String and args[0] == "RAND ()"
            args[0] = "RAND (%d)" % ($random.rand * 10**5).to_i
          end
          order_without_seed(*args)
        end
        alias_method_chain :order, :seed
      end
    end

    back_to_date(Time.parse(ENV['TEST_DATETIME']))
    puts "\n        ------------------------- TEST_DATETIME=#{ENV['TEST_DATETIME']} -------------------------"
  end

  def dump_file_name(minimal = false)
    s = if minimal
          "minimal_seed.sql"
        else
          get_test_datetime
          "seed_#{ENV['TEST_DATETIME']}.sql"
        end
    File.join(Rails.root, "features/personas/dumps", s)
  end

  private

  def get_test_datetime(reset = false)
    ENV['TEST_DATETIME'] = if not ENV['TEST_DATETIME'].blank? and not reset
                             ENV['TEST_DATETIME']
                           elsif reset or (existing_dump_file_name = Dir.glob(File.join(Rails.root, "features/personas/dumps", "seed_*.sql")).sample).nil?
                             # NOTE we do not test on saturday or sunday
                             begin
                               new_date = rand(3.years.ago..3.years.from_now)
                             end while new_date.saturday? or new_date.sunday? or not (6..18).include?(new_date.hour)
                             new_date.to_time.iso8601
                           else
                             existing_dump_file_name.match(/.*seed_(.*)\.sql/).captures.first
                           end
  end

end
