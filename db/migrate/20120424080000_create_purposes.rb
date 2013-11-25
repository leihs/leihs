class CreatePurposes < ActiveRecord::Migration
  def change
    create_table :purposes, :force => true do |t|
      t.text :description
    end
    
    change_table :order_lines do |t|
      t.belongs_to :purpose
    end
    change_table :contract_lines do |t|
      t.belongs_to :purpose
    end

    [Contract].each do |k|
      k.all.each do |x|
        description = x.read_attribute(:purpose)
        next if description.nil?
        p_id = Purpose.create(description: description).id
        "#{k}Line".constantize.update_all({purpose_id: p_id}, {id: x.send("#{k}_line_ids".downcase), purpose_id: nil})
      end    
    end
    
  end
end
