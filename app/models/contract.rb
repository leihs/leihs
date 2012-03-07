# == Schema Information
#
# Table name: contracts
#
#  id                :integer(4)      not null, primary key
#  user_id           :integer(4)
#  inventory_pool_id :integer(4)
#  status_const      :integer(4)      default(1)
#  purpose           :text
#  created_at        :datetime
#  updated_at        :datetime
#  note              :text
#  delta             :boolean(1)      default(TRUE)
#

# A Contract is a #Document containing #ContractLine s. It gets
# created from an #Order, once the #Order is acknowledged by an
# #InventoryPool manager.
#
# The page "Flow" inside the models.graffle document shows the
# various steps though which a #Document goes from #Order to
# finally closed Contract.
#
class Contract < Document

  belongs_to :inventory_pool # common for sibling classes
  belongs_to :user
  
  has_many :contract_lines, :dependent => :destroy, :order => 'start_date ASC, end_date ASC, contract_lines.created_at ASC' #Rails3.1# TODO ContractLin#default_scope
  has_many :item_lines, :dependent => :destroy, :order => 'start_date ASC, end_date ASC, contract_lines.created_at ASC'
  has_many :option_lines, :dependent => :destroy, :order => 'start_date ASC, end_date ASC, contract_lines.created_at ASC'
  has_many :models, :through => :item_lines, :uniq => true, :order => 'contract_lines.start_date ASC, contract_lines.end_date ASC, models.name ASC'
  has_many :items, :through => :item_lines, :uniq => false
  has_many :options, :through => :option_lines, :uniq => true

  # TODO validates_uniqueness [user_id, inventory_pool_id, status_const] if status_consts == Contract::UNSIGNED

  UNSIGNED = 1
  SIGNED = 2
  CLOSED = 3

  STATUS = {_("Unsigned") => UNSIGNED, _("Signed") => SIGNED, _("Closed") => CLOSED }

  def status_string
    n = STATUS.index(status_const)
    n.nil? ? status_const : n
  end

  # alias
  def lines( reload = false )
    contract_lines( reload )
  end

#########################################################################

  scope :unsigned, where(:status_const => Contract::UNSIGNED)
  scope :signed, where(:status_const => Contract::SIGNED)
  scope :closed, where(:status_const => Contract::CLOSED)
  scope :signed_or_closed, where(:status_const => [Contract::SIGNED, Contract::CLOSED])
  
  # OPTIMIZE use INNER JOIN (:joins => :contract_lines) -OR- union :unsigned + :signed (with lines) 
  scope :pending, select("DISTINCT contracts.*").
                  joins("LEFT JOIN contract_lines ON contract_lines.contract_id = contracts.id").
                  where(["contracts.status_const = :signed
                                         OR (contracts.status_const = :unsigned AND
                                             contract_lines.contract_id IS NOT NULL)",
                                        {:signed => Contract::SIGNED,
                                         :unsigned => Contract::UNSIGNED }])

  scope :by_inventory_pool, lambda { |inventory_pool| where(:inventory_pool_id => inventory_pool) }

#########################################################################

  def self.search2(query)
    return scoped unless query

    sql = select("DISTINCT contracts.*").joins(:user, :models, :items)
      # TODO ??
      #joins("LEFT JOIN `users` ON `users`.`id` = `contracts`.`user_id`").
      #joins("LEFT JOIN `contract_lines` ON `contract_lines`.`contract_id` = `contracts`.`id` AND `contract_lines`.`type` IN ('ItemLine')").
      #joins("LEFT JOIN `models` ON `models`.`id` = `contract_lines`.`model_id`").
      #joins("LEFT JOIN `items` ON `items`.`id` = `contract_lines`.`item_id`")

    w = query.split.map do |x|
      s = []
      s << "CONCAT_WS(' ', contracts.id, contracts.note) LIKE '%#{x}%'"
      s << "CONCAT_WS(' ', users.login, users.firstname, users.lastname, users.badge_id) LIKE '%#{x}%'"
      s << "models.name LIKE '%#{x}%'"
      s << "items.inventory_code LIKE '%#{x}%'"
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
        when :status_const
          sql = sql.where(k => v)
      end
    end
    sql
  end
  
#########################################################################
  
  def as_json(options = {})
    options ||= {} # NOTE workaround, because options is nil, is this a BUG ??
    options.delete_if {|k,v| v.nil? }

    default_options = {:only => [:id, :status_const, :created_at, :updated_at]}
    more_json = {}
    
    if (with = options[:with])
      if with[:user]
        user_default_options = {:include => {:user => {:only => [:firstname, :lastname, :id, :phone, :email],
                                                       :methods => [:image_url] }}}
        default_options.deep_merge!(user_default_options.deep_merge(with[:user]))
      end
      
      if with[:lines]
        more_json['lines'] = lines.as_json(with[:lines])
      end
    end
        
    json = super(default_options.deep_merge(options))
    json['type'] =  :contract # needed for templating (type identifier)
    json.merge(more_json)
    
=begin
    default_options = {:only => [:id, :inventory_pool_id, :purpose, :status_const, :created_at, :updated_at],
                       :include => {:items => {}}}

    more_json = {}

    if (with = options[:with])
      if with[:user]
        user_default_options = {:include => {:user => {:only => [:firstname, :lastname, :id, :phone, :email],
                                                       :methods => [:image_url] }}}
        default_options.deep_merge!(user_default_options.deep_merge(with[:user]))
      end
    end
    
    json = super(default_options.deep_merge(options))
    json['type'] = :contract # needed for templating (type identifier)
    
    # FIXME give additional attributes (:inventory_code, :returned_date) ??
    lines_array = contract_lines.map {|cl| OpenStruct.new({:start_date => cl.start_date, :end_date => cl.end_date, :model => cl.model, :quantity => cl.quantity}) }
    
    # FIXME do we really want to group ??
    sorted_and_grouped_contract_lines = lines_array.sort {|a,b| [a.start_date, a.end_date, a.model.id] <=> [b.start_date, b.end_date, b.model.id] }.
                                          group_by {|cl| [cl.start_date, cl.end_date, cl.model] }
    
    lines_hash = sorted_and_grouped_contract_lines.map {|k,v| {:start_date => k[0],
                                                      :end_date => k[1],
                                                      :model => {:name => k[2].name, :manufacturer => k[2].manufacturer}, :quantity => v.sum(&:quantity)} }
    
    json[:lines] = lines_hash
    
    json.merge(more_json)
=end
  end

#########################################################################

  # TODO: we don't have a single place where we call sign without a current_user, except in a new test
  #       -> eliminate the default value and the assignement current_user ||=
  def sign(contract_lines = nil, current_user = nil)
    current_user ||= self.user
    
    transaction do
      update_attributes({:status_const => Contract::SIGNED, :created_at => Time.now}) 
  
      if contract_lines and contract_lines.any? { |cl| cl.item }
  
        # Forces handover date to be today.
        contract_lines.each {|cl| cl.update_attributes(:start_date => Date.today) if cl.start_date != Date.today }
        
        log_history(_("Contract %d has been signed by %s") % [self.id, self.user.name], current_user.id)
        
        lines_for_new_contract = self.contract_lines - contract_lines
        if not lines_for_new_contract.empty?
          new_contract = user.get_current_contract(self.inventory_pool)
    
          lines_for_new_contract.each do |cl|
            cl.update_attributes(:contract => new_contract)
          end
        end        
      end
    end
  end

  def close
    update_attributes(:status_const => Contract::CLOSED)
  end

end

