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
  
  scope :search, lambda { |query|
    return scoped if query.blank?

    sql = select("DISTINCT orders.*").joins(:user, :models)

    query.split.each{|q|
      q = "%#{q}%"
      sql = sql.where(User.arel_table[:login].matches(q).
                      or(User.arel_table[:firstname].matches(q)).
                      or(User.arel_table[:lastname].matches(q)).
                      or(User.arel_table[:badge_id].matches(q)).
                      or(Model.arel_table[:name].matches(q)))
    }
    sql
  }

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
      errors.add(:base, _("This order is not approvable because some reserved models are not available or the inventory pool is closed on either the start or enddate."))
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
          # FIXME go through contract.add_lines ??
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

  def update_lines(line_ids, line_id_model_id, start_date, end_date, current_user_id) # TODO remove current_user_id when not used anymore
    OrderLine.transaction do
      lines.find(line_ids).each do |line|
        line.start_date = Date.parse(start_date) if start_date
        line.end_date = Date.parse(end_date) if end_date

        # TODO remove log changes (use the new audits)
        change = ""
        # TODO the model swapping is not implemented on the client side
        if (new_model_id = line_id_model_id[line.id.to_s]) 
          line.model = line.order.user.models.find(new_model_id) 
          change = _("[Model %s] ") % line.model 
        end
        change += line.changes.map do |c|
          what = c.first
          if what == "model_id"
            from = Model.find(from).to_s
            _("Swapped from %s ") % [from]
          else
            from = c.last.first
            to = c.last.last
            _("Changed %s from %s to %s") % [what, from, to]
          end
        end.join(', ')

        log_change(change, current_user_id) if line.save
      end
    end
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
    lines.detect {|l| l.purpose_id and l.purpose }.try(:purpose) || Purpose.new(:order_lines => lines, :description => read_attribute(:purpose)) 
  end
  
  # NOTE override the column attribute (until leihs 2 is switched off)
  def purpose=(description)
    purpose.change_description(description, lines)
    write_attribute :purpose, description
  end 

  def change_purpose(new_purpose, user_id)
    change = _("Purpose changed '%{from}' for '%{to}'") % { :from => self.purpose.try(:description), :to => new_purpose}
    log_change(change, user_id)
    self.purpose = new_purpose
  end  

  ############################################
  
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

