# Reading a MySQL View
class ContractLinesBundle < ActiveRecord::Base
  include Delegation::ContractLinesBundle

  class << self
    include BundleFinder
  end

  def readonly?
    true
  end

  self.table_name = "contract_lines"

  default_scope -> {
    select("IFNULL(contract_lines.contract_id, CONCAT_WS('_', contract_lines.status, contract_lines.user_id, contract_lines.inventory_pool_id)) AS id,
            MAX(contract_lines.status) AS status, # NOTE this is a trick to get 'signed' in case there are both 'signed' and 'closed' lines
            contract_lines.user_id,
            contract_lines.inventory_pool_id,
            contract_lines.delegated_user_id,
            IF(SUM(groups.is_verification_required) > 0, 1, 0) AS verifiable_user,
            COUNT(partitions.id) > 0 AS verifiable_user_and_model,
            MAX(contract_lines.created_at) AS created_at").
    joins("LEFT JOIN (groups_users, groups, partitions)
            ON contract_lines.user_id = groups_users.user_id
            AND groups_users.group_id = groups.id
            AND groups.is_verification_required = 1
            AND contract_lines.inventory_pool_id = groups.inventory_pool_id
            AND partitions.group_id = groups.id
            AND partitions.model_id = contract_lines.model_id").
    group("IFNULL(contract_lines.contract_id, contract_lines.status), contract_lines.user_id, contract_lines.inventory_pool_id").
    order(nil)
  }

  def id
    r = id_before_type_cast
    if r.nil? # it is not persisted
      "#{status}_#{user_id}_#{inventory_pool_id}"
    elsif r.is_a? String and r.include?('_')
      r
    else
      r.to_i
    end
  end

  belongs_to :inventory_pool
  belongs_to :user

  belongs_to :contract, foreign_key: :id
  delegate :note, to: :contract

  LINE_CONDITIONS = -> (r){ where("(contract_lines.status IN ('#{:signed}', '#{:closed}') AND contract_lines.contract_id = ?)
                                    OR (contract_lines.status NOT IN ('#{:signed}', '#{:closed}') AND contract_lines.user_id = ? AND contract_lines.status = ?)",
                                  r.id, r.user_id, r.status) }

  has_many :contract_lines, LINE_CONDITIONS, foreign_key: :inventory_pool_id, primary_key: :inventory_pool_id
  has_many :item_lines, LINE_CONDITIONS, foreign_key: :inventory_pool_id, primary_key: :inventory_pool_id
  has_many :option_lines, LINE_CONDITIONS, foreign_key: :inventory_pool_id, primary_key: :inventory_pool_id
  has_many :models, -> { order('models.product ASC').uniq }, :through => :item_lines
  has_many :items, :through => :item_lines
  has_many :options, -> { uniq }, :through => :option_lines
  alias :lines :contract_lines

  # NOTE we need this method because the association has a inventory_pool_id as primary_key
  def contract_line_ids
    contract_lines.pluck :id
  end

  #######################################################

  STATUSES = [:unsubmitted, :submitted, :rejected, :approved, :signed, :closed]

  def status
    read_attribute(:status).to_sym
  end

  STATUSES.each do |status|
    scope status, -> {where(status: status)}
  end

  scope :signed_or_closed, -> {where(status: [:signed, :closed])}

  #######################################################

  scope :with_verifiable_user, -> { having("verifiable_user = 1") }
  scope :with_verifiable_user_and_model, -> { having("verifiable_user_and_model = 1") }
  scope :no_verification_required, -> { having("verifiable_user_and_model != 1") }

  def is_to_be_verified
    verifiable_user_and_model == 1
  end

  #######################################################

  scope :search, lambda { |query|
                 return all if query.blank?

                 sql = uniq.
                     joins("INNER JOIN users ON users.id = contract_lines.user_id").
                     joins("LEFT JOIN contracts ON contract_lines.id = contracts.id AND contract_lines.status IN ('#{:signed}', '#{:closed}')").
                     joins("LEFT JOIN options ON options.id = contract_lines.option_id").
                     joins("LEFT JOIN models ON models.id = contract_lines.model_id").
                     joins("LEFT JOIN items ON items.id = contract_lines.item_id")

                 query.split.each { |q|
                   qq = "%#{q}%"
                   sql = sql.where(
                       # "contract_lines.id = '#{q}' OR
                       #  CONCAT_WS(' ', contracts.note, users.login, users.firstname, users.lastname, users.badge_id,
                       #                 models.manufacturer, models.product, models.version, options.product,
                       #                 options.version, items.inventory_code, items.properties) LIKE '%#{qq}%'"

                       ##arel_table[:id].eq(q.numeric? ? q : 0) # NOTE we cannot use eq(q) because alphanumeric string is truncated and casted to integer, causing wrong matches (contracts.id)
                       arel_table[:id].eq(q)
                           .or(Contract.arel_table[:note].matches(qq))
                           .or(User.arel_table[:login].matches(qq))
                           .or(User.arel_table[:firstname].matches(qq))
                           .or(User.arel_table[:lastname].matches(qq))
                           .or(User.arel_table[:badge_id].matches(qq))
                           .or(Model.arel_table[:manufacturer].matches(qq))
                           .or(Model.arel_table[:product].matches(qq))
                           .or(Model.arel_table[:version].matches(qq))
                           .or(Option.arel_table[:product].matches(qq))
                           .or(Option.arel_table[:version].matches(qq))
                           .or(Item.arel_table[:inventory_code].matches(qq))
                           .or(Item.arel_table[:properties].matches(qq))
                   )
                 }
                 sql
               }

  ############################################

  def self.filter(params, user = nil, inventory_pool = nil)
    contracts = if user
                  user.contracts
                elsif inventory_pool
                  inventory_pool.contracts
                else
                  all
                end

    contracts = contracts.where(status: params[:status]) if params[:status]

    contracts = contracts.search(params[:search_term]) unless params[:search_term].blank?

    contracts = if params[:no_verification_required]
                  contracts.no_verification_required
                elsif params[:to_be_verified]
                  contracts.with_verifiable_user_and_model
                elsif params[:from_verifiable_users]
                  contracts.with_verifiable_user
                else
                  contracts
                end

    contracts = contracts.where(id: params[:id]) if params[:id]

    if r = params[:range]
      created_at_date = Arel::Nodes::NamedFunction.new "CAST", [arel_table[:created_at].as("DATE")]
      contracts = contracts.where(created_at_date.gteq(r[:start_date])) if r[:start_date]
      contracts = contracts.where(created_at_date.lteq(r[:end_date])) if r[:end_date]
    end

    contracts = contracts.order(arel_table[:created_at].desc)

    contracts = contracts.default_paginate params unless params[:paginate] == "false"
    contracts
  end

  ############################################

  def min_date
    unless lines.blank?
      lines.min { |x| x.start_date }[:start_date]
    else
      nil
    end
  end

  def max_date
    unless lines.blank?
      lines.max { |x| x.end_date }[:end_date]
    else
      nil
    end
  end

  def max_range
    return nil if lines.blank?
    line = lines.max_by { |x| (x.end_date - x.start_date).to_i }
    (line.end_date - line.start_date).to_i + 1
  end

  ############################################

  def time_window_min
    lines.minimum(:start_date) || Date.today
  end

  def time_window_max
    lines.maximum(:end_date) || Date.today
  end

  def next_open_date(x)
    x ||= Date.today
    if inventory_pool
      inventory_pool.next_open_date(x)
    else
      x
    end
  end

  ############################################

  def add_lines(quantity, model, current_user, start_date = nil, end_date = nil, delegated_user_id = nil)
    if end_date and start_date and end_date < start_date
      end_date = start_date
    end

    attrs = { inventory_pool: inventory_pool,
              status: status,
              quantity: 1,
              model: model,
              start_date: start_date || time_window_min,
              end_date: end_date || next_open_date(time_window_max),
              delegated_user_id: delegated_user_id || self.delegated_user_id}

    new_lines = quantity.to_i.times.map do
      line = user.item_lines.create(attrs) do |l|
        l.purpose = lines.first.purpose if status == :submitted and lines.first.try :purpose
      end

      unless line.new_record?
        line.log_change(_("Added") + " #{attrs[:quantity]} #{attrs[:model].name} #{attrs[:start_date]} #{attrs[:end_date]}", current_user.try(:id))
      end

      line
    end

    new_lines
  end

  ################################################################

  def remove_line(line, user_id)
    if [:unsubmitted, :submitted, :approved].include?(status)
      line.log_change _("Removed %{q} %{m}") % {:q => line.quantity, :m => line.model.name}, user_id # OPTIMIZE we log before actually remove because association
      if lines.include? line and line.destroy
        true
      else
        false
      end
    else
      false
    end
  end

  ############################################

  def purpose_descriptions
    # join purposes
    lines.sort.map { |x| x.purpose.to_s }.uniq.delete_if { |x| x.blank? }.join("; ")
  end
  alias :purpose :purpose_descriptions

  ############################################

  # TODO dry with ContractLine
  def target_user
    if user.is_delegation and delegated_user
      delegated_user
    else
      user
    end
  end

  def submit(purpose_description = nil)
    # TODO relate to Application Settings (required_purpose)
    if purpose_description
      purpose = Purpose.create :description => purpose_description
      contract_lines.each { |cl| cl.purpose = purpose }
    end

    if approvable?
      contract_lines.each { |cl| cl.update_attributes(status: :submitted) }

      Notification.order_submitted(self, false)
      Notification.order_received(self, true)
      true
    else
      false
    end
  end

  ############################################

  def approvable?
    contract_lines.all? &:approvable?
  end

  def approve(comment, send_mail = true, current_user = nil, force = false)
    if approvable? or (force and current_user.has_role?(:lending_manager, inventory_pool))
      contract_lines.each { |cl| cl.update_attributes(status: :approved) }
      begin
        Notification.order_approved(self, comment, send_mail, current_user)
      rescue Exception => exception
        # archive problem in the log, so the admin/developper
        # can look up what happened
        logger.error "#{exception}\n    #{exception.backtrace.join("\n    ")}"
        self.errors.add(:base,
                        _("The following error happened while sending a notification email to %{email}:\n") % {:email => target_user.email} +
                            "#{exception}.\n" +
                            _("That means that the user probably did not get the approval mail and you need to contact him/her in a different way."))
      end
      true
    else
      false
    end
  end

  def reject(comment, current_user)
    lines.all? {|line| line.update_attributes(status: :rejected) } and Notification.order_rejected(self, comment, true, current_user)
  end

  def sign(current_user, selected_lines, note = nil, delegated_user_id = nil)
    transaction do
      contract = Contract.create do |contract|
        contract.note = note

        selected_lines.each do |cl|
          attrs = {
              contract: contract,
              status: :signed,
              handed_over_by_user_id: current_user.id
          }

          attrs[:delegated_user] = user.delegated_users.find(delegated_user_id) if delegated_user_id

          # Forces handover date to be today.
          attrs[:start_date] = Date.today if cl.start_date != Date.today

          cl.update_attributes(attrs)

          contract.contract_lines << cl
        end
      end
      if contract.valid?
        log_history(_("Contract %d has been signed by %s") % [contract.id, contract.contract_lines.first.user.name], current_user.id)
      end
      contract
    end
  end

  def handed_over_by_user
    if [:signed, :closed].include? status
      lines.first.handed_over_by_user
    else
      nil
    end
  end

  ################################################################

  def total_quantity
    lines.sum(:quantity)
  end

  def total_price
    lines.to_a.sum(&:price)
  end

  #######################
  #

  def log_history(text, user_id)
    user_id = user_id.id if user_id.is_a? User
    lines.each do |line|
      line.histories.create(text: text, user_id: user_id, type_const: History::ACTION)
    end
  end

  def has_changes?
    lines.any? do |line|
      history = line.histories.order('created_at DESC, id DESC').first
      history.nil? ? false : history.type_const == History::CHANGE
    end
  end

  #
  #######################

end
