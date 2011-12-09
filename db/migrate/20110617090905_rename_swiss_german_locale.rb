# -*- encoding : utf-8 -*-
class RenameSwissGermanLocale < ActiveRecord::Migration
  def self.up
    gsw = Language.first(:conditions => {:locale_name => 'gsw_CH@zurich'})
    unless gsw.nil?
      gsw.update_attributes(:locale_name => 'gsw_CH', :name => 'Schwizertüütsch')
    end
  end

  def self.down
    gsw = Language.first(:conditions => {:locale_name => 'gsw_CH'})
    unless gsw.nil?
      gsw.update_attributes(:locale_name => 'gsw_CH@zurich', :name => 'Züritüütsch')
    end
  end
end
