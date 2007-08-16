class Kaufvorgang < ActiveRecord::Base
	
	has_one :gegenstand
	belongs_to :updater, :class_name => 'User', :foreign_key => 'updater_id'
	
end
