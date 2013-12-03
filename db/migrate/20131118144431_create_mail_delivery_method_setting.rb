class CreateMailDeliveryMethodSetting < ActiveRecord::Migration
  def change

    change_table(:settings) do |t|
      t.string :mail_delivery_method
    end

    Setting.reset_column_information

    setting = Setting.first
    if not setting
      setting = Setting.create(:mail_delivery_method => 'smtp')
    else
      setting.update_attributes(:mail_delivery_method => 'smtp')
    end

  end
end
