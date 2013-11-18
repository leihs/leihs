class CreateMailDeliveryMethodSetting < ActiveRecord::Migration
  def change

    change_table(:settings) do |t|
      t.string :mail_delivery_method
    end

    Setting.reset_column_information

    Setting.create(:mail_delivery_method => 'smtp')

  end
end
