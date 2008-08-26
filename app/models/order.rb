class Order < Document

  belongs_to :inventory_pool # common for sibling classes
  belongs_to :user
  has_many :order_lines, :dependent => :destroy
  has_many :models, :through => :order_lines, :uniq => true

  has_one :backup, :class_name => "Backup::Order", :dependent => :destroy #TODO delete when nullify # TODO acts_as_backupable

  
  acts_as_commentable
  acts_as_ferret :fields => [ :user_login, :lines_model_names, :purpose ],
                 :store_class_name => true
                 # TODO union of results :or_default => true
                 
  NEW = 1
  SUBMITTED = 2
  APPROVED = 3
  REJECTED = 4

  # alias
  def lines
    order_lines
  end

#########################################################################

  named_scope :new_orders, :conditions => {:status_const => Order::NEW}, :order => 'created_at DESC'
  named_scope :submitted_orders, :conditions => {:status_const => Order::SUBMITTED}, :order => 'created_at DESC'
  named_scope :approved_orders, :conditions => {:status_const => Order::APPROVED}, :order => 'created_at DESC'
  named_scope :rejected_orders, :conditions => {:status_const => Order::REJECTED}, :order => 'created_at DESC'


#########################################################################

  def approvable?
    if self.status_const == Order::APPROVED
      return false
    else 
      return lines.all? {|l| l.available? }
    end
  end


  # TODO forward Options
  # approves order then generates a new contract and contract_lines for each item
  def approve(comment)
    if approvable?
      self.status_const = Order::APPROVED
      remove_backup
      save

      if has_changes?
        OrderMailer.deliver_changed(self, comment)
      else
        OrderMailer.deliver_approved(self, comment)
      end

      contract = user.get_current_contract(self.inventory_pool)
      order_lines.each do |ol|
        ol.quantity.times do
          contract.contract_lines << ContractLine.new(:model => ol.model,
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
    #old: save if new_record? # OPTIMIZE

    if approvable?
      self.status_const = Order::SUBMITTED
      split_and_assign_to_inventory_pool
      save
      return true
    else
      return false
    end
  end

  # keep the user required quantity 
  def update_line(line_id, required_quantity, user_id)
    line = order_lines.find(line_id)
    original_quantity = line.quantity
        
    max_available = line.model.maximum_available_in_period(line.start_date, line.end_date, line)

    line.quantity = [required_quantity, 0].max # TODO force positive quantity in DocumentLine

    # check if it can be served by a single inventory pool, or split the line
    # TODO check availability
    if line.quantity <= max_available
      single_inventory_pool = line.model.inventory_pools.any? {|ip| ip.items.count(:conditions => {:model_id => line.model.id}) >= line.quantity }
      unless single_inventory_pool
        total_quantity = line.quantity
        line.quantity = 1 # TODO determine quantity to split
        l = line.clone
        l.quantity = total_quantity - line.quantity
        lines << l
      end
      # TODO refresh interface with new line
    end
    
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
  
    
  # TODO acts_as_backupable ##################
  def has_backup?
    !self.backup.nil?
  end

  def to_backup
    self.backup = Backup::Order.new(attributes) #.reject {|key, value| key == "id" }
    
    order_lines.each do |ol|
      backup.order_lines << Backup::OrderLine.new(ol.attributes) #.reject {|key, value| key == "id" }     
    end

    save
  end  
 
  def from_backup
    self.attributes = backup.attributes.reject {|key, value| key == "order_id" } # or key == "id" 
    
    order_lines.clear
    
    backup.order_lines.each do |ol|
      order_lines << OrderLine.new(ol.attributes.reject {|key, value| key == "order_id" }) # or key == "id" 
    end
        
    histories.each {|h| h.destroy if h.created_at > backup.created_at}
    
    remove_backup
    
    save
  end
  
  def remove_backup
    self.backup = nil
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

#old#    
#    if !inventory_pool and lines.first #temp#
#      #temp#
#      #    # TODO check availability and TODO scope user's visible inventory pools
#      #  
#      #    # collect possible inventory pools 
#      #    #inventory_pools = models.inventory_pools #old# models.collect(&:inventory_pools).flatten.uniq
#      #
#      #    # construct combinations of inventory pools
#      #    ip_set = []
#      #    lines.each do |l|
#      #      ip_set << l.models.collect(&:inventory_pools)
#      #    end
#      #
#      #    # split a single line if cannot be served by a single inventory pool
#      #
#      #    # define mandatory inventory pools
#
#      #temp#    
#      # TODO temp determines related inventory_pool
#      first_line_with_items = lines.detect {|l| !l.model.items.empty? } 
#      inventory_pool = first_line_with_items.model.items.first.inventory_pool
#    
#      # TODO split order for different inventory pools
#      to_split_lines = lines.select {|l| not l.model.inventory_pools.any?{|ip| ip == inventory_pool }}
#      unless to_split_lines.empty?
#        o = Order.new(self.attributes)
#        to_split_lines.each {|l| o.lines << l }
#        o.submit
#      end
#  
#      update_attribute(:inventory_pool, inventory_pool)
#    end
    
  end


  
end
