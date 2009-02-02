# Superclass for Order and Contract
class Document < ActiveRecord::Base
  self.abstract_class = true
  
  has_many :histories, :as => :target, :dependent => :destroy, :order => 'created_at ASC'

  # compares two objects in order to sort them
  def <=>(other)
    self.created_at <=> other.created_at
  end

  def to_s
    "#{id}"
  end

  def quantity
    lines.collect(&:quantity).sum
  end

################################################################
  def time_window_min
    self.lines.collect(&:start_date).min || Date.today
  end
  
  def time_window_max
    self.lines.collect(&:end_date).max || Date.today
  end
  
  def next_open_date(x)
    x = Date.today if x.nil?
    if inventory_pool
      while not inventory_pool.is_open_on?(x) do
        x += 1.day
      end
    end
    x
  end
  
################################################################

  def add_line(quantity, model, user_id, start_date = nil, end_date = nil, inventory_pool = nil)
      end_date = start_date if end_date and start_date and end_date < start_date
      
      document_line = "#{self.class}Line".constantize
      o = document_line.new(:quantity => quantity || 1,
                            :model_id => model.to_i,
                            :start_date => start_date || time_window_min,
                            :end_date => end_date || next_open_date(time_window_max))
      o.inventory_pool = inventory_pool if inventory_pool and o.is_a?(OrderLine) # TODO: This is not very nice :-(
      
      log_change(_("Added") + " #{quantity} #{model.name} #{start_date} #{end_date}", user_id)
      lines << o
  end

  def swap_line(line_id, model_id, user_id)
    line = lines.find(line_id.to_i)
    if (line.model.id != model_id.to_i)
      model = Model.find(model_id.to_i)
      change = _("Swapped %{from} for %{to}") % { :from => line.model.name, :to => model.name}
      line.model = model
      log_change(change, user_id)
      line.save
    end
  end

  def update_time_line(line_id, start_date, end_date, user_id)
    line = lines.find(line_id)
    original_start_date = line.start_date
    original_end_date = line.end_date
    line.start_date = start_date
    line.end_date = [start_date, end_date].max
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
    histories.create(:text => text, :user_id => user_id, :type_const => History::CHANGE)
  end
  
  def log_history(text, user_id)
    histories.create(:text => text, :user_id => user_id, :type_const => History::ACTION)
  end
  
  def has_changes?
    history = histories.find(:first, :order => 'created_at DESC, id DESC')
    history.nil? ? false : history.type_const == History::CHANGE
  end
  #
  #######################


  def timeline
    events = []
    lines.each do |l|
      events << Event.new(:start => l.start_date, :end => l.end_date, :title =>l.model.name)
    end

    xml = Event.xml_wrap(events)
    
    f_name = "/javascripts/timeline/document_#{self.id}.xml"
    File.open("public#{f_name}", 'w') { |f| f.puts xml }
    f_name
  end

#  protected
  
  def user_login
    user.login
  end
  
  def lines_model_names
    mn = [] 
    lines.each do |l|
      mn << l.model.name  
    end
    mn.uniq.join(" ")
  end

  
end