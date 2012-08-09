# An Order is a #Document containing #OrderLine s.
# It's created by a customer, that wants to borrow
# some stuff. In the workflow of the lending process
# once the Order gets to the #InventoryPool manager
# it is copied over into a #Contract.
#
# An Order can not contain #Options - contrary to a
# #Contract, that can have them.
#
# The page "Flow" inside the models.graffle document shows the
# various steps though which a #Document goes from #Order to
# finally closed Contract.
#
class Order < Document

  attr_protected :created_at

  belongs_to :inventory_pool # common for sibling classes
  belongs_to :user
  has_many :order_lines, :dependent => :destroy, :order => 'start_date ASC, end_date ASC, created_at ASC'
  has_many :models, :through => :order_lines, :uniq => true

  validate :validates_order_lines

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
  def lines( reload = false )
    order_lines( reload )
  end

#########################################################################
  
  default_scope order('orders.created_at ASC')
  
  scope :unsubmitted, where(:status_const => Order::UNSUBMITTED)
  scope :submitted, where(:status_const => Order::SUBMITTED) # OPTIMIZE N+1 select problem
  scope :approved, where(:status_const => Order::APPROVED) # TODO 0501 remove
  scope :rejected, where(:status_const => Order::REJECTED)

  scope :by_inventory_pool,  lambda { |inventory_pool| where(:inventory_pool_id => inventory_pool) }

#########################################################################
  
  def self.search2(query)
    return scoped unless query

    sql = select("DISTINCT orders.*").joins(:user, :models)

    w = query.split.map do |x|
      s = []
      s << "CONCAT_WS(' ', users.login, users.firstname, users.lastname, users.badge_id) LIKE '%#{x}%'"
      s << "models.name LIKE '%#{x}%'"
      "(%s)" % s.join(' OR ')
    end.join(' AND ')
    sql.where(w)
  end

  def self.filter2(options)
    sql = scoped
    options.each_pair do |k,v|
      case k
        when :inventory_pool_id
          sql = sql.where(k => v)
      end
    end
    sql
  end

#########################################################################

  def is_approved?
    self.status_const == Order::APPROVED
  end

  def approvable?
    if is_approved?
      errors.add(:base, _("This order has already been approved."))
      false
    elsif lines.empty?
      errors.add(:base, _("This order is not approvable because doesn't have any models."))
      false
    elsif lines.all? {|l| l.available? }
      true
    else
      errors.add(:base, _("This order is not approvable because some reserved models are not available."))
      false
    end
  end
  alias :is_approvable :approvable?


  # approves order then generates a new contract and item_lines for each item
  def approve(comment, send_mail = true, current_user = nil, force = false)
    if approvable? || force
      self.status_const = Order::APPROVED
      save

      contract = user.get_current_contract(self.inventory_pool)
      order_lines.each do |ol|
        ol.quantity.times do
          contract.item_lines.create( :model => ol.model,
                                      :quantity => 1,
                                      :start_date => ol.start_date,
                                      :end_date => ol.end_date,
                                      :purpose => ol.purpose )
        end
      end   
      contract.save

      begin
        Notification.order_approved(self, comment, send_mail, current_user)
      rescue Exception => exception
        # archive problem in the log, so the admin/developper
        # can look up what happened
        logger.error "#{exception}\n    #{exception.backtrace.join("\n    ")}"
        self.errors.add(:base,
          _("The following error happened while sending a notification email to %{email}:\n") % { :user => user.email } +
          "#{exception}.\n" +
          _("That means that the user probably did not get the approval mail and you need to contact him/her in a different way."))
      end

      return true
    else
      return false
    end
  end

  # submits order
  def submit(purpose_description = nil)
    # TODO relate to Application Settings (required_purpose)
    self.purpose = purpose_description if purpose_description

    if approvable?
      self.status_const = Order::SUBMITTED
      split_and_assign_to_inventory_pool

      Notification.order_submitted(self, purpose_description, false)
      Notification.order_received(self, purpose_description, true)
      return true
    else
      return false
    end
  end

  def add_line(quantity, model, user_id, start_date = nil, end_date = nil, inventory_pool = nil)
    quantity = quantity.to_i
    line = lines.where(:model_id => model, :start_date => start_date, :end_date => end_date).first
    if line
      line.quantity += quantity
      if line.save
        log_change( _("Incremented quantity from %i to %i for %s") % [line.quantity-quantity, line.quantity, model.name], user_id )        
      end
    else
      line = super
    end
    line
  end

  # keep the user required quantity, force positive quantity 
  def update_line(order_line_id, required_quantity, user_id)
    order_line = order_lines.find(order_line_id)
    original_quantity = order_line.quantity
        
    max_available = order_line.maximum_available_quantity

    order_line.quantity = [required_quantity, 0].max
    order_line.save

    change = _("Changed quantity for %{model} from %{from} to %{to}") % { :model => order_line.model.name, :from => original_quantity, :to => order_line.quantity }
    if required_quantity > max_available
      @flash_notice = _("Maximum number of items available at that time is %{max}") % {:max => max_available}
      change += " " + _("(maximum available: %{max})") % {:max => max_available}
    end
    log_change(change, user_id)
    [order_line, change]
  end
  
  def remove_line(line_or_id, user_id)
    if [APPROVED, REJECTED].include? status_const
      false
    elsif status_const == UNSUBMITTED or (status_const == SUBMITTED and lines.size > 1)
      super
    else
      false
    end
  end

  ############################################

  # NOTE override the column attribute (until leihs 2 is switched off)
  # NOTE all lines should have the same purpose
  def purpose
    lines.detect {|l| l.purpose }.try(:purpose)
  end
  
  # NOTE override the column attribute (until leihs 2 is switched off)
  def purpose=(description)
    p = self.purpose || Purpose.new(:order_lines => lines)
    p.change_description(description, lines)
  end 

  def change_purpose(new_purpose, user_id)
    change = _("Purpose changed '%{from}' for '%{to}'") % { :from => self.purpose.try(:description), :to => new_purpose}
    log_change(change, user_id)
    self.purpose = new_purpose
  end  

  ############################################

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
    status_const == Order::SUBMITTED 
  end

  def waiting_for_hand_over
    if is_approved? and lines.maximum(:start_date) >= Date.today
      contract = user.current_contract(inventory_pool)
      return true if contract and not contract.lines.empty?
    end
    return false
  end
  
  ############################################

  def min_date
    unless order_lines.blank?
      order_lines.min {|x| x.start_date}[:start_date]
    else
      nil
    end
  end
  
  def max_date
    unless order_lines.blank?
      order_lines.max {|x| x.end_date }[:end_date]
    else
      nil
    end
  end
  
  ############################################
  
  private
  
  # TODO assign based on the order_lines' inventory_pools
  def split_and_assign_to_inventory_pool
      inventory_pools = lines.flat_map(&:inventory_pool).uniq
      inventory_pools.each do |ip|
        if ip == inventory_pools.first
          self.inventory_pool = ip
          next          
        end
        to_split_lines = lines.select {|l| l.inventory_pool == ip }
        attrs = self.attributes.reject {|k,v| [:id, :created_at, :updated_at].include? k.to_sym }
        o = Order.new(attrs)
        o.inventory_pool = ip
        to_split_lines.each {|l| o.lines << l }
        o.save        
      end
      save
  end

  def validates_order_lines
    # TODO ?? model.inventory_pools.include?(order.inventory_pool)
    errors.add(:base, _("Invalid order_lines")) if lines.any? {|l| !l.valid? }
  end
  
end

