class UpdateSettingsWithLogoUrl < ActiveRecord::Migration

  def change

    change_table(:settings) do |t|
      t.string :logo_url
    end

    Setting.reset_column_information

    Setting.create(:logo_url => nil)

  end

end
