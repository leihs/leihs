class InfoUrl < ActiveRecord::Migration
  def self.up
		add_column( 'gegenstands', 'info_url', :string, :limit => 40 )
  end

  def self.down
		remove_column( 'gegenstands', 'info_url' )
  end
end
