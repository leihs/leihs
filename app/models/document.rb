# Superclass for Order and Contract
class Document < ActiveRecord::Base
  self.abstract_class = true
  
  # TODO refactor in subclasses ?
  has_many :histories, :as => :target, :dependent => :destroy, :order => 'created_at ASC'

  # compares two objects in order to sort them
  def <=>(other)
    self.created_at <=> other.created_at
  end

################################################################
  def time_window_min
    d1 = Array.new
    self.lines.each do |ol|
      d1 << ol.start_date
    end
    d1.min
  end
  
  def time_window_max
    d2 = Array.new
    self.lines.each do |ol|
      d2 << ol.end_date
    end
    d2.max
  end
  
################################################################
  def add_line(quantity, model, user_id, start_date = nil, end_date = nil, line_group = nil)
      start_date ||= time_window_min
      end_date ||= time_window_max
    
      c = "#{self.class}Line".constantize
      o = c.new(:quantity => quantity,
                :model_id => model.to_i,
                :start_date => start_date,
                :end_date => end_date,
                :line_group => line_group)
      log_change(_("Added") + " #{quantity} #{model.name} #{start_date} #{end_date}", user_id)
      lines << o
  end

  # TODO group_line dependency
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

  # with group_line dependency # TODO test
  def update_time_line(line_id, start_date, end_date, user_id)
    line = lines.find(line_id)
    group_lines = line.get_my_group_lines
    
    group_lines.each do |l|
      original_start_date = l.start_date
      original_end_date = l.end_date
      l.start_date = start_date
      l.end_date = end_date
      if l.save
        change = _("Changed dates for %{model} from %{from} to %{to}") % { :model => l.model.name, :from => "#{original_start_date} - #{original_end_date}", :to => "#{l.start_date} - #{l.end_date}" }
        log_change(change, user_id)
      else
        l.errors.each_full do |msg|
          errors.add_to_base msg
        end
      end
    end
  end 
  
  # with group_line dependency # TODO test
  def remove_line(line_id, user_id)
    begin
      line = lines.find(line_id.to_i)
      group_lines = line.get_my_group_lines
  
      group_lines.each do |l|
        change = _("Removed %{m}") % { :m => l.model.name }
        l.destroy
        lines.delete(l)
        log_change(change, user_id)
      end
    rescue
      # prevent exception trying to delete a line already deleted within a line_group
    end
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


  # TODO temp timeline
  def timeline
    events = []
    lines.each do |l|
      events << Event.new(l.start_date, l.end_date, l.model.name)
#      events << Event.new(:start => l.start_date,
#                          :end => l.end_date,
#                          :title => l.model.name,
#                          :isDuration => true)
    end

    xml = Event.wrap(events)
    
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