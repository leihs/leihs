class UpdateSettingsWithLogoUrl < ActiveRecord::Migration

  def change

    change_table(:settings) do |t|
      t.string :logo_url
    end

  end

end
