class ValidatingOptions < ActiveRecord::Migration
  def self.up

    destroyed = []
    Option.all.each do |option|
      next if destroyed.include?(option.id)
      unless option.valid?
        conflicting_options = Option.all(:conditions => {:inventory_code => option.inventory_code, :inventory_pool_id => option.inventory_pool_id })
        conflicting_options.sort! {|x,y| y.option_lines.count <=> x.option_lines.count }
        conflicting_options[1..-1].each do |co|
          co.option_lines.each do |ol|
            ol.update_attributes(:option => conflicting_options[0])
          end
          co.destroy
          destroyed << co.id if co.destroyed?
        end
      end
    end

  end

  def self.down
  end
end
