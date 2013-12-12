class Contract < ActiveRecord::Base
  include LineModules::GroupedAndMergedLines

  has_many :histories, :as => :target, :dependent => :destroy, :order => 'created_at ASC'
  has_many :actions, :as => :target, :class_name => "History", :order => 'created_at ASC', :conditions => "type_const = #{History::ACTION}"

  belongs_to :inventory_pool
  belongs_to :user

  has_many :contract_lines, :dependent => :destroy, :order => 'start_date ASC, end_date ASC, contract_lines.created_at ASC' #Rails3.1# TODO ContractLin#default_scope
  has_many :item_lines, :dependent => :destroy, :order => 'start_date ASC, end_date ASC, contract_lines.created_at ASC'
  has_many :option_lines, :dependent => :destroy, :order => 'start_date ASC, end_date ASC, contract_lines.created_at ASC'
  has_many :models, :through => :item_lines, :uniq => true, :order => 'contract_lines.start_date ASC, contract_lines.end_date ASC, models.name ASC'
  has_many :items, :through => :item_lines, :uniq => false
  has_many :options, :through => :option_lines, :uniq => true
  belongs_to :handed_over_by_user, :class_name => "User"

#########################################################################

  validates_presence_of :inventory_pool, :status

  validate do
    errors.add(:base, _("Invalid contract_lines")) if lines.any? {|l| not l.valid? }
    errors.add(:base, _("The start_date is not unique")) if [:signed, :closed].include?(status) and lines.group(:start_date).count.keys.size != 1
  end

#########################################################################

  # alias
  def lines( reload = false )
    contract_lines( reload )
  end

  # compares two objects in order to sort them
  def <=>(other)
    self.created_at <=> other.created_at
  end

  def to_s
    "#{id}"
  end

  TIMEOUT_MINUTES = 30

#########################################################################

  # TODO do we really want this ??
  # default_scope order('contracts.created_at ASC')

#########################################################################

  def status
    read_attribute(:status).to_sym
  end

  [:unsubmitted, :submitted, :rejected, :approved, :signed, :closed].each do |status|
    scope status, where(status: status)
  end
  scope :submitted_or_approved_or_rejected, where(status: [:submitted, :approved, :rejected])
  scope :signed_or_closed, where(status: [:signed, :closed])
  scope :not_empty, joins(:contract_lines).uniq

  # OPTIMIZE use INNER JOIN (:joins => :contract_lines) -OR- union :approved + :signed (with lines)
  scope :pending, select("DISTINCT contracts.*").
      joins("LEFT JOIN contract_lines ON contract_lines.contract_id = contracts.id").
      where("contracts.status = '#{:signed}'
                         OR (contracts.status = '#{:approved}' AND
                             contract_lines.contract_id IS NOT NULL)")

  scope :by_inventory_pool, lambda { |inventory_pool| where(:inventory_pool_id => inventory_pool) }

#########################################################################

  scope :search, lambda { |query|
    return scoped if query.blank?

    sql = select("DISTINCT contracts.*").
        joins("LEFT JOIN `users` ON `users`.`id` = `contracts`.`user_id`").
        joins("INNER JOIN `contract_lines` ON `contract_lines`.`contract_id` = `contracts`.`id`").
        joins("LEFT JOIN `options` ON `options`.`id` = `contract_lines`.`option_id`").
        joins("LEFT JOIN `models` ON `models`.`id` = `contract_lines`.`model_id`").
        joins("LEFT JOIN `items` ON `items`.`id` = `contract_lines`.`item_id`")

    query.split.each{|q|
      qq = "%#{q}%"
      sql = sql.where(arel_table[:id].eq(q).
                          or(arel_table[:note].matches(qq)).
                          or(User.arel_table[:login].matches(qq)).
                          or(User.arel_table[:firstname].matches(qq)).
                          or(User.arel_table[:lastname].matches(qq)).
                          or(User.arel_table[:badge_id].matches(qq)).
                          or(Model.arel_table[:name].matches(qq)).
                          or(Option.arel_table[:name].matches(qq)).
                          or(Item.arel_table[:inventory_code].matches(qq)))
    }
    sql
  }

  def self.filter(params, user = nil, inventory_pool = nil)
    contracts = if user
                  user.contracts
                elsif inventory_pool
                  # NOTE in case we are using the global search, we already have an inner join defined in contract#search scope, preventing displaying empty contracts
                  if params[:search_term].blank?
                    inventory_pool.contracts.not_empty
                  else
                    inventory_pool.contracts
                  end
                else
                  scoped
                end
    contracts = contracts.search(params[:search_term]) unless params[:search_term].blank?
    contracts = contracts.where(:status => params[:status]) if params[:status]
    contracts = contracts.where(:id => params[:ids]) if params[:ids]
    contracts = contracts.where(Contract.arel_table[:created_at].gt(params[:range][:start_date])) if params[:range] and params[:range][:start_date]
    contracts = contracts.where(Contract.arel_table[:created_at].lt(params[:range][:end_date])) if params[:range] and params[:range][:end_date]
    contracts = contracts.order(Contract.arel_table[:created_at].desc)
    contracts = contracts.paginate(:page => params[:page]||1, :per_page => [(params[:per_page].try(&:to_i) || 20), 100].min) unless params[:paginate] == "false"
    contracts
  end

#########################################################################

  def sign(current_user, selected_lines = nil)
    selected_lines ||= self.contract_lines

    if selected_lines.empty? # sign is only possible if there is at least one line
      errors.add(:base, _("This contract is not signable because it doesn't have any contract lines."))
      false
    elsif selected_lines.all? {|l| l.purpose.nil? }
      errors.add(:base, _("This contract is not signable because none of the lines have a purpose."))
      false
    elsif selected_lines.any? {|l| l.item.nil? }
      errors.add(:base, _("This contract is not signable because some lines are not assigned."))
      false
    else
      transaction do
        unless (lines_for_new_contract = self.contract_lines - selected_lines).empty?
          new_contract = dup
          new_contract.save
          lines_for_new_contract.each do |cl|
            cl.update_attributes(:contract => new_contract)
          end
          contract_lines.reload
        end

        # Forces handover date to be today.
        selected_lines.each {|cl|
          cl.update_attributes(:start_date => Date.today) if cl.start_date != Date.today
        }

        update_attributes({:status => :signed, :created_at => Time.now, :handed_over_by_user_id => current_user.id})
        log_history(_("Contract %d has been signed by %s") % [self.id, self.user.name], current_user.id)
      end
      true
    end
  end

  def close
    update_attributes(status: :closed)
  end

  def action
    if status == :submitted
      :acknowledge
    elsif status == :approved
      :hand_over
    elsif status == :signed
      :take_back
    else
      nil
    end
  end

  ############################################

  def is_approved?
    self.status == :approved
  end

  def approvable?
    if is_approved?
      errors.add(:base, _("This order has already been approved."))
      false
    elsif lines.empty?
      errors.add(:base, _("This order is not approvable because doesn't have any models."))
      false
    elsif purpose.to_s.blank?
      errors.add(:base, _("Please provide a purpose..."))
      false
    elsif lines.all? {|l| l.available? }
      true
    else
      errors.add(:base, _("This order is not approvable because some reserved models are not available or the inventory pool is closed on either the start or enddate."))
      false
    end
  end
  alias :is_approvable :approvable?

  def approve(comment, send_mail = true, current_user = nil, force = false)
    if approvable? || force
      update_attributes(status: :approved)

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

  def submit(purpose_description = nil)
    # TODO relate to Application Settings (required_purpose)
    self.purpose = purpose_description if purpose_description

    if approvable?
      update_attributes(status: :submitted)

      Notification.order_submitted(self, purpose_description, false)
      Notification.order_received(self, purpose_description, true)
      return true
    else
      return false
    end
  end

  ############################################

  def update_lines(line_ids, line_id_model_id, start_date, end_date, current_user_id) # TODO remove current_user_id when not used anymore
    ContractLine.transaction do
      lines.find(line_ids).each do |line|
        line.start_date = Date.parse(start_date) if start_date
        line.end_date = Date.parse(end_date) if end_date

        # TODO remove log changes (use the new audits)
        change = ""
        # TODO the model swapping is not implemented on the client side
        if (new_model_id = line_id_model_id[line.id.to_s])
          line.model = line.contract.user.models.find(new_model_id)
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

  ############################################

  def min_date
    unless lines.blank?
      lines.min {|x| x.start_date}[:start_date]
    else
      nil
    end
  end

  def max_date
    unless lines.blank?
      lines.max {|x| x.end_date }[:end_date]
    else
      nil
    end
  end

  def max_range
    return nil if lines.blank?
    line = lines.max_by {|x| (x.end_date - x.start_date).to_i }
    (line.end_date - line.start_date).to_i + 1
  end

  ############################################

  def purpose
    if [:unsubmitted, :submitted, :rejected].include? status
      # NOTE all lines should have the same purpose
      lines.detect {|l| l.purpose_id and l.purpose }.try(:purpose) || Purpose.new(:contract_lines => lines, :description => read_attribute(:purpose))
    else
      lines.sort.map {|x| x.purpose.to_s }.uniq.delete_if{|x| x.blank? }.join("; ")
    end
  end

  def purpose=(description)
    if [:unsubmitted, :submitted, :rejected].include? status
      purpose.change_description(description, lines)
    else
      Purpose.create(description: description, contract_lines: lines.where(purpose_id: nil))
    end
  end

  def change_purpose(new_purpose, user_id)
    change = _("Purpose changed '%s' for '%s'") % [self.purpose.try(:description), new_purpose]
    log_change(change, user_id)
    self.purpose = new_purpose
  end

################################################################


  def total_quantity
    lines.sum(:quantity)
  end
  alias :quantity :total_quantity # TODO remove quantity where is used

  def total_price
    lines.sum(&:price)
  end

################################################################

  def time_window_min
    lines.minimum(:start_date) || Date.today
  end

  def time_window_max
    lines.maximum(:end_date) || Date.today
  end

  def max_single_range
    lines.select("DATEDIFF(end_date, start_date) + 1 as time_window").
        reorder("time_window DESC").
        limit(1).
        first.try(:time_window).to_i
  end

  def next_open_date(x)
    x ||= Date.today
    if inventory_pool
      inventory_pool.next_open_date(x)
    else
      x
    end
  end

################################################################

  def add_lines(quantity, model, user_id, start_date = nil, end_date = nil)
    end_date = start_date if end_date and start_date and end_date < start_date

    new_lines = if false # TODO model.is_a? Option
                         # TODO option_lines.create
                else
                  attr = { :quantity => 1,
                           :model => model,
                           :start_date => start_date || time_window_min,
                           :end_date => end_date || next_open_date(time_window_max) }
                  quantity.to_i.times.map do
                    line = item_lines.create(attr) do |l|
                      l.purpose = lines.first.purpose if status == :submitted and !lines.empty? and lines.first.purpose
                    end
                    log_change(_("Added") + " #{attr[:quantity]} #{attr[:model].name} #{attr[:start_date]} #{attr[:end_date]}", user_id) unless line.new_record?
                    line
                  end
                end
    lines.reload # NOTE force reload contract_lines association
    new_lines
  end

  def swap_line(line_id, model_id, user_id)
    line = lines.find(line_id.to_i)
    if (line.model.id != model_id.to_i)
      model = Model.find(model_id.to_i)
      change = _("Swapped %{from} for %{to}") % { :from => line.model.name, :to => model.name}
      line.item = nil if line.is_a?(ItemLine)
      line.model = model
      log_change(change, user_id)
      line.save
    end
  end

  def update_time_line(line_id, start_date, end_date, user_id)
    line = lines.find(line_id)
    start_date ||= line.start_date
    end_date ||= line.end_date
    original_start_date = line.start_date
    original_end_date = line.end_date
    line.start_date = start_date
    line.end_date = [start_date, end_date].max
    if line.save
      change = _("Changed dates for %{model} from %{from} to %{to}") % { :model => line.model.name, :from => "#{original_start_date} - #{original_end_date}", :to => "#{line.start_date} - #{line.end_date}" }
      log_change(change, user_id)
    else
      line.errors.each_full do |msg|
        errors.add(:base, msg)
      end
    end
  end

################################################################

  def remove_lines(lines, user_id)
    transaction do
      lines.each {|l| remove_line(l, user_id) }
    end
  end

  def remove_line(line_or_id, user_id)
    if [:unsubmitted, :submitted, :approved].include?(status)
      line = line_or_id.is_a?(ContractLine) ? line_or_id : lines.find(line_or_id.to_i)
      if lines.delete(line)
        change = _("Removed %{q} %{m}") % { :q => line.quantity, :m => line.model.name }
        log_change(change, user_id)

        # we do not keep empty contracts
        if lines.reload.empty?
          self.destroy
        end

        true
      else
        false
      end
    else
      false
    end
  end

  #######################
  #
  def log_change(text, user_id)
    user_id = user_id.id if user_id.is_a? User
    histories.create(:text => text, :user_id => user_id, :type_const => History::CHANGE) unless (user and user_id == user.id)
  end

  def log_history(text, user_id)
    user_id = user_id.id if user_id.is_a? User
    histories.create(:text => text, :user_id => user_id, :type_const => History::ACTION)
  end

  def has_changes?
    history = histories.order('created_at DESC, id DESC').first
    history.nil? ? false : history.type_const == History::CHANGE
  end
  #
  #######################

end

