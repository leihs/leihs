class Order < ActiveRecord::Base

  belongs_to :user
  has_many :order_lines, :dependent => :destroy
  has_many :histories, :as => :target, :dependent => :destroy, :order => 'created_at ASC'

  has_one :backup, :class_name => "Backup::Order", :dependent => :destroy #TODO delete when nullify # TODO acts_as_backupable

  
  acts_as_commentable
  acts_as_ferret :fields => [ :user_login, :order_lines_model_names ],
                 :store_class_name => true
                 # TODO union of results :or_default => true
                 
  NEW = 1
  APPROVED = 2
  REJECTED = 3
  
  def self.new_orders
    find(:all, :conditions => {:status_const => Order::NEW})
  end


  def add_line(quantity, model, user_id, start_date = nil, end_date = nil)
    o = OrderLine.new(:quantity => quantity,
                      :model_id => model.to_i,
                      :start_date => start_date,
                      :end_date => end_date)
    log_change(_("Added") + " #{quantity} #{model.name} #{start_date} #{end_date}", user_id)
    order_lines << o
  end
  
  def update_line(line_id, required_quantity, user_id)
    line = order_lines.find(line_id)
    original = line.quantity
    
    max_available = line.model.maximum_available_in_period(line.start_date, line.end_date, line_id)

    line.quantity = required_quantity < max_available ? required_quantity : max_available
    change = _("Changed quantity for %{model} from %{from} to %{to}") % { :model => line.model.name, :from => original.to_s, :to => line.quantity }

    if required_quantity > max_available
      @flash_notice = _("Maximum number of items available at that time is %{max}") % {:max => max_available}
      change += " " + _("(maximum available)")
    end
    log_change(change, user_id)
    line.save
    [line, change]
  end
  
    # TODO merge with update_line ?
   def update_time_line(line_id, start_date, end_date, user_id)
    line = order_lines.find(line_id)
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

    #[line, change] # not used
  end 
  
  def swap_line(line_id, model_id, user_id)
    line = order_lines.find(line_id.to_i)
    if (line.model.id != model_id.to_i)
      model = Model.find(model_id.to_i)
      change = _("Swapped %{from} for %{to}") % { :from => line.model.name, :to => model.name}
      line.model = model
      log_change(change, user_id)
      line.save
    end
    [line, change] # TODO where this return is used?
  end
  
  def remove_line(line_id, user_id)
    line = order_lines.find(line_id.to_i)
    change = _("Removed %{m}") % { :m => line.model.name }
    line.destroy
    log_change(change, user_id)
    #[line, change]
  end  

  def change_purpose(new_purpose, user_id)
    change = _("Purpose changed '%{from}' for '%{to}'") % { :from => self.purpose, :to => new_purpose}
    self.purpose = new_purpose
    log_change(change, user_id)
    save
    # [line, change]
  end  
  
  def swap_user(new_user_id, admin_user_id)
    user = User.find(new_user_id)
    if (user.id != self.user_id.to_i)
      change = _("User swapped %{from} for %{to}") % { :from => self.user.login, :to => user.login}
      self.user = user
      log_change(change, admin_user_id)
      save
    end
    # [line, change]
  end  
  
  #TODO: If you want to copy this method somewhere else, think about creating a acts_as_....
  def log_change(text, user_id)
    histories << History.new(:text => text, :user_id => user_id, :type_const => History::CHANGE)
  end
  
  #TODO: If you want to copy this method somewhere else, think about creating a acts_as_....
  def log_history(text, user_id)
    histories << History.new(:text => text, :user_id => user_id, :type_const => History::ACTION)
  end
  
  #TODO: If you want to copy this method somewhere else, think about creating a acts_as_....
  def has_changes?
    history = histories.find(:first, :order => 'created_at DESC, id DESC')
    history.nil? ? false : history.type_const == History::CHANGE
  end
  
  
  def time_window_min
    d1 = Array.new
    self.order_lines.each do |ol|
      d1 << ol.start_date
    end
    d1.min
  end
  
  def time_window_max
    d2 = Array.new
    self.order_lines.each do |ol|
      d2 << ol.end_date
    end
    d2.max
  end
  
  # TODO acts_as_backupable ##################
  def has_backup?
    !self.backup.nil?
  end

  def to_backup
    self.backup = Backup::Order.new(attributes.reject {|key, value| key == "id" })
    
    self.order_lines.each do |ol|
      self.backup.order_lines << Backup::OrderLine.new(ol.attributes.reject {|key, value| key == "id" })     
    end
    
    self.save
  end  
 
  def from_backup
    self.attributes = self.backup.attributes.reject {|key, value| key == "id" or key == "order_id" }
    
    self.order_lines.clear
    self.backup.order_lines.each do |ol|
      self.order_lines << OrderLine.new(ol.attributes.reject {|key, value| key == "id" or key == "order_id" })
    end
    
    self.histories.each {|h| h.destroy if h.created_at > self.backup.created_at}
    
    self.backup = nil
    
    self.save
  end
  ############################################
  
  
  private
 
  
  def user_login
    self.user.login
  end
  
  def order_lines_model_names
    mn = [] 
    self.order_lines.each do |ol|
      mn << ol.model.name  
    end
    mn.uniq.join(" ")
  end
  
end
