class MoveEnglishUsToEnglishGb < ActiveRecord::Migration
  def up
    english_us = Language.where(:locale_name => 'en-US').first
    english_gb = Language.where(:locale_name => 'en-GB').first

    unless english_us.nil? or english_gb.nil?
      # Need to do it this way because the association doesn't seem to be two-way?
      english_us_users = User.where(:language_id => english_us.id)
      english_us_users.each do |user|
        user.language = english_gb
        user.save
      end
      english_us.active = false
      english_us.save
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
