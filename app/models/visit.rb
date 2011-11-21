# A Visit is an event on a particular date, on which a specific
# customer should come to pick up or return items - or from the other perspective:
# when an inventory pool manager should hand over some items to or get them back from the customer.
#
# 'action' says if we want to have hand_overs or take_backs. action can be either of those two:
# * "hand_over"
# * "take_back"
#
# Reading a MySQL View

class Visit < ActiveRecord::Base
  set_primary_key "inventory_pool_id, user_id, status_const, date" # needed by the eager-loader and the identity-map

  belongs_to :user
  belongs_to :inventory_pool

  def line_ids
    contract_line_ids.split(',').map(&:to_i)
  end
  def contract_lines
    @contract_lines ||= ContractLine.find(line_ids)
  end
  alias :lines :contract_lines

  #######################################################
  
  scope :hand_over, lambda { where(:status_const => Contract::UNSIGNED) }
  scope :take_back, lambda { where(:status_const => Contract::SIGNED) }

  #######################################################

  def as_json(options={})
    options ||= {} # NOTE workaround, because options is nil, is this a BUG ??

    # OPTIMIZE because "comparison of ItemLine with OptionLine failed"
    lines_array = contract_lines.map {|cl| OpenStruct.new({:start_date => cl.start_date, :end_date => cl.end_date, :model => cl.model, :quantity => cl.quantity}) }
    
    sorted_and_grouped_contract_lines = lines_array.sort_by {|cl| [cl.start_date, cl.end_date, cl.model_id]}.group_by {|cl| [cl.start_date, cl.end_date, cl.model] }
    
    lines_hash = sorted_and_grouped_contract_lines.map {|k,v| { :start_date => k[0],
                                                                :end_date => k[1],
                                                                :model => {:name => k[2].name, :manufacturer => k[2].manufacturer},
                                                                :quantity => v.sum(&:quantity) } }

    default_options = {:only => [:quantity, :date],
                       :methods => [:is_overdue],
                       :include => {:user => {:only => [:id, :firstname, :lastname, :phone, :email]} } }
                       
    default_options.deep_merge(options)
    json = super(default_options)
    
    case action
      when "take_back"
        latest_remind = user.reminders.last
        json.merge!({:latest_remind => (latest_remind and latest_remind.created_at > date) ? latest_remind.created_at.to_s(:db) : nil})
    end
    
    json.merge({:type => action,
                :contract_line_ids => line_ids,
                :lines => lines_hash, ###
                :min_date => lines_hash.min {|x| x[:start_date]}[:start_date], ###
                :max_date => lines_hash.max {|x| x[:end_date]}[:end_date] }) ###
  end

  #######################################################

  # compares two objects in order to sort them
  # def <=>(other)
    # self.date <=> other.date
  # end  

  def is_overdue
    date < Date.today
  end

end
