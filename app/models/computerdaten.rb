class Computerdaten < ActiveRecord::Base
	
	belongs_to :gegenstand
	belongs_to :updater, :class_name => 'User', :foreign_key => 'updater_id'
	
end
