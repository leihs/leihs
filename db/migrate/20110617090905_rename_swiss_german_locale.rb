# -*- encoding : utf-8 -*-
class RenameSwissGermanLocale < ActiveRecord::Migration
  def up
    gsw = Language.where(:locale_name => 'gsw_CH@zurich').first
    unless gsw.nil?
      gsw.update_attributes(:locale_name => 'gsw_CH', :name => 'Schwizertüütsch')
    end
  end

  def down
    gsw = Language.where(:locale_name => 'gsw_CH').first
    unless gsw.nil?
      gsw.update_attributes(:locale_name => 'gsw_CH@zurich', :name => 'Züritüütsch')
    end
  end
end
