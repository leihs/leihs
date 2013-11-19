class UpdateSettingsWithLogoUrl < ActiveRecord::Migration

  def change

    change_table(:settings) do |t|
      t.string :logo_url
    end

    Setting.reset_column_information

    setting = Setting.first
    if not setting
      setting = Setting.create(:logo_url => nil)
    else
      setting.update_attributes(:logo_url => nil)
    end

  end

end
