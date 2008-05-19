class Order < Document

  belongs_to :user
  has_many :order_lines, :dependent => :destroy

  has_one :backup, :class_name => "Backup::Order", :dependent => :destroy #TODO delete when nullify # TODO acts_as_backupable

  
  acts_as_commentable
  acts_as_ferret :fields => [ :user_login, :order_lines_model_names ],
                 :store_class_name => true
                 # TODO union of results :or_default => true
                 
  NEW = 1
  APPROVED = 2
  REJECTED = 3

  # alias
  def lines
    order_lines
  end

#########################################################################

  def self.new_orders
    find(:all, :conditions => {:status_const => Order::NEW})
  end

  def self.approved_orders
    find(:all, :conditions => {:status_const => Order::APPROVED})
  end

  def self.rejected_orders
    find(:all, :conditions => {:status_const => Order::REJECTED})
  end

#########################################################################


  def approvable?
    lines.all? {|l| l.available? }
  end


  def approve(comment)
    if approvable?
      self.status_const = Order::APPROVED
      self.backup = nil
      save
      if has_changes?
        OrderMailer.deliver_changed(self, comment)
      else
        OrderMailer.deliver_approved(self, comment)
      end
      return true
    else
      return false
    end
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
  
    
  def remove_option(option_id, user_id)
    option = Option.find(option_id.to_i)
    change = _("Removed Option: %{o}") % { :o => ("(" + option.quantity.to_s + ") " + option.name) }
    option.destroy
    log_change(change, user_id)
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
    self.backup = Backup::Order.new(attributes) #.reject {|key, value| key == "id" }
    
    self.order_lines.each do |ol|
      self.backup.order_lines << Backup::OrderLine.new(ol.attributes) #.reject {|key, value| key == "id" }     
    end
    
    self.save
  end  
 
  def from_backup
    self.attributes = self.backup.attributes.reject {|key, value| key == "order_id" } # or key == "id" 
    
    self.order_lines.clear
    self.backup.order_lines.each do |ol|
      self.order_lines << OrderLine.new(ol.attributes.reject {|key, value| key == "order_id" }) # or key == "id" 
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
