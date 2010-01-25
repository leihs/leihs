class Order < Document

  attr_protected :created_at

  belongs_to :inventory_pool # common for sibling classes
  belongs_to :user
  has_many :order_lines, :dependent => :destroy, :order => 'start_date ASC, end_date ASC, created_at ASC'
  has_many :models, :through => :order_lines, :uniq => true

  has_one :backup, :class_name => "Backup::Order", :dependent => :destroy #TODO delete when nullify # TODO acts_as_backupable

  acts_as_commentable

  define_index do
    indexes :purpose
    indexes user(:login), :as => :user_login
    indexes user(:badge_id), :as => :user_badge_id
    indexes models(:name), :as => :model_names
    
    has :inventory_pool_id, :user_id, :status_const
    has backup(:id), :as => :backup_id
    
    set_property :delta => true
  end

                 
  UNSUBMITTED = 1
  SUBMITTED = 2
  APPROVED = 3
  REJECTED = 4

  STATUS = {_("Unsubmitted") => UNSUBMITTED, _("Submitted") => SUBMITTED, _("Approved") => APPROVED, _("Rejected") => REJECTED }

  def status_string
    n = STATUS.index(status_const)
    n.nil? ? status_const : n
  end

  # alias
  def lines
    order_lines
  end

#########################################################################
  
  default_scope :order => 'created_at ASC'
  
  named_scope :unsubmitted, :conditions => {:status_const => Order::UNSUBMITTED}
  named_scope :submitted, :conditions => {:status_const => Order::SUBMITTED}, :include => :backup # OPTIMIZE N+1 select problem
  named_scope :approved, :conditions => {:status_const => Order::APPROVED} # TODO 0501 remove
  named_scope :rejected, :conditions => {:status_const => Order::REJECTED}

  named_scope :by_inventory_pool,  lambda { |inventory_pool| { :conditions => { :inventory_pool_id => inventory_pool } } }

# 0501 rename /sphinx_/ and remove relative named_scope
  sphinx_scope(:sphinx_submitted) { { :with => {:status_const => Order::SUBMITTED}, :include => :backup } }
  sphinx_scope(:sphinx_approved) { { :with => {:status_const => Order::APPROVED} } }
  sphinx_scope(:sphinx_rejected) { { :with => {:status_const => Order::REJECTED} } }


#########################################################################

  def is_approved?
    self.status_const == Order::APPROVED
  end

  def approvable?
    if is_approved?
      return false
    else 
      return lines.all? {|l| l.available? }
    end
  end


  # TODO 13** forward purpose
  # approves order then generates a new contract and item_lines for each item
  def approve(comment, send_mail = true, current_user = nil)
    if approvable?
      self.status_const = Order::APPROVED
      remove_backup
      save

      Notification.order_approved(self, comment, send_mail, current_user)
      
      contract = user.get_current_contract(self.inventory_pool)
      order_lines.each do |ol|
        ol.quantity.times do
          contract.item_lines.create( :model => ol.model,
                                      :quantity => 1,
                                      :start_date => ol.start_date,
                                      :end_date => ol.end_date)
        end
      end   
      contract.save
      
      return true
    else
      return false
    end
  end

  # submits order
  def submit(purpose = nil)
    self.purpose = purpose if purpose
    save

    if approvable?
      self.status_const = Order::SUBMITTED
      split_and_assign_to_inventory_pool
      save
      
      Notification.order_submitted(self, purpose, false)

      return true
    else
      return false
    end
  end

  # keep the user required quantity, force positive quantity 
  def update_line(line_id, required_quantity, user_id)
    line = order_lines.find(line_id)
    original_quantity = line.quantity
        
    max_available = line.model.maximum_available_in_period_for_document_line(line.start_date, line.end_date, line)

    line.quantity = [required_quantity, 0].max
    
    line.save

    change = _("Changed quantity for %{model} from %{from} to %{to}") % { :model => line.model.name, :from => original_quantity, :to => line.quantity }
    if required_quantity > max_available
      @flash_notice = _("Maximum number of items available at that time is %{max}") % {:max => max_available}
      change += " " + _("(maximum available: %{max})") % {:max => max_available}
    end
    log_change(change, user_id)
    [line, change]
  end
  
  def change_purpose(new_purpose, user_id)
    change = _("Purpose changed '%{from}' for '%{to}'") % { :from => self.purpose, :to => new_purpose}
    self.purpose = new_purpose
    log_change(change, user_id)
    save
  end  

  # OPTIMIZE scope new_user_id by current_inventory_pool
  def swap_user(new_user_id, admin_user_id)
    user = User.find(new_user_id)
    if (user.id != self.user_id.to_i)
      change = _("User swapped %{from} for %{to}") % { :from => self.user.login, :to => user.login}
      self.user = user
      log_change(change, admin_user_id)
      save
    end
  end  
  
 
  def deletable_by_user?
    !has_backup? and status_const == Order::SUBMITTED 
  end
    
  # TODO acts_as_backupable ##################
  def has_backup?
    !self.backup.nil?
  end

  def to_backup
    self.backup = Backup::Order.new(attributes)
    
    order_lines.each do |ol|
      backup.order_lines.create(ol.attributes)
    end

    save
  end  
 
  def from_backup
    self.attributes = backup.attributes.reject {|key, value| key == "order_id" }
    
    order_lines.clear
    
    backup.order_lines.each do |ol|
      order_lines.create(ol.attributes.reject {|key, value| key == "order_id" }) 
    end
        
    histories.each {|h| h.destroy if h.created_at > backup.created_at}
    
    remove_backup
    
    save
  end
  
  def remove_backup
    self.backup = nil
  end

  def waiting_for_hand_over
    if is_approved? and lines.collect(&:start_date).max >= Date.today
      contract = user.current_contract(inventory_pool)
      return true if contract and not contract.lines.empty?
    end
    return false
  end
  
  ############################################

  private
  
  # TODO assign based on the order_lines' inventory_pools
  def split_and_assign_to_inventory_pool

      inventory_pools = lines.collect(&:inventory_pool).flatten.uniq
      inventory_pools.each do |ip|
        if ip == inventory_pools.first
          self.inventory_pool = ip
          next          
        end
        to_split_lines = lines.select {|l| l.inventory_pool == ip }
        o = Order.new(self.attributes)
        o.inventory_pool = ip
        to_split_lines.each {|l| o.lines << l }
        o.save        
      end
    
  end
  
end
