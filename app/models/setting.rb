class Setting < ActiveRecord::Base

  validates_presence_of :local_currency_string,
                        :email_signature,
                        :default_email
  validates_presence_of :disable_borrow_section_message, if: :disable_borrow_section?
  validates_presence_of :disable_manage_section_message, if: :disable_manage_section?

  #validates_numericality_of :smtp_port, :greater_than => 0

  validates_format_of :default_email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i

  def self.method_missing(name, *args, &block)
    @@singleton ||= first # fetch the singleton from the database
    @@singleton.try :send, name
  end

  before_create do
    raise 'Setting is a singleton' if Setting.count > 0
  end

  after_save do
    @@singleton = nil
    begin
      # Only reading from the initializers is not enough, they are only read during
      # server start, making changes of the time zone during runtime impossible.
      if self.time_zone_changed? # Check for existence of time_zone first, in case the migration for time_zone has not run yet
        Rails.configuration.time_zone = self.time_zone
        Time.zone = self.time_zone
      end
    rescue
      logger.info 'Timezone setting could not be loaded. Did the migrations run?'
    end
  end

end
