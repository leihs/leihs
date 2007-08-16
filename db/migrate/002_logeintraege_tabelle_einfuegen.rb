class LogeintraegeTabelleEinfuegen < ActiveRecord::Migration
  def self.up
		create_table( :logeintraege,
					:options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' ) do |logeintraege|
			logeintraege.column( :lock_version, :int, :null => false )
			logeintraege.column( :updated_at, :timestamp, :default => 'CURRENT_TIMESTAMP' )
			logeintraege.column( :created_at, :timestamp, :default => Time.now.at_midnight + 10.hours )
			logeintraege.column( :user_id, :int )
			logeintraege.column( :aktion, :string, :limit => 40, :null => false, :default => 'unbekannt' )
			logeintraege.column( :kommentar, :text )
		end
  end

  def self.down
		drop_table :logeintraege
  end
end
