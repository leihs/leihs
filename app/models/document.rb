# Superclass for Order and Contract
class Document < ActiveRecord::Base

  self.abstract_class = true
  
  has_many :histories, :as => :target, :dependent => :destroy, :order => 'created_at ASC'

  

  def swap_line(line_id, model_id, user_id)
    line = lines.find(line_id.to_i)
    if (line.model.id != model_id.to_i)
      model = Model.find(model_id.to_i)
      change = _("Swapped %{from} for %{to}") % { :from => line.model.name, :to => model.name}
      line.model = model
      log_change(change, user_id)
      line.save
    end
    [line, change] # TODO where this return is used?
  end

  def update_time_line(line_id, start_date, end_date, user_id)
    line = lines.find(line_id)
    original_start_date = line.start_date
    original_end_date = line.end_date
    line.start_date = start_date
    line.end_date = end_date

    if line.save
      change = _("Changed dates for %{model} from %{from} to %{to}") % { :model => line.model.name, :from => "#{original_start_date} - #{original_end_date}", :to => "#{line.start_date} - #{line.end_date}" }
      log_change(change, user_id)
    else
      line.errors.each_full do |msg|
        errors.add_to_base msg
      end
    end
  end 
  
  def remove_line(line_id, user_id)
    line = lines.find(line_id.to_i)
    change = _("Removed %{m}") % { :m => line.model.name }
    line.destroy
    lines.delete(line)
    log_change(change, user_id)
  end  
  


  #######################
  #
  def log_change(text, user_id)
    histories << History.new(:text => text, :user_id => user_id, :type_const => History::CHANGE)
  end
  
  def log_history(text, user_id)
    histories << History.new(:text => text, :user_id => user_id, :type_const => History::ACTION)
  end
  
  def has_changes?
    history = histories.find(:first, :order => 'created_at DESC, id DESC')
    history.nil? ? false : history.type_const == History::CHANGE
  end
  #
  #######################

  
end