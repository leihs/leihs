class Order < ActiveRecord::Base

  belongs_to :user
  has_many :order_lines
  has_many :histories, :as => :target, :dependent => :destroy, :order => 'created_at ASC'

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


  def add_line(quantity, model, user_id)
    o = OrderLine.new(:quantity => quantity,
                      :model_id => model.to_i)
    log_change(_("Added") + " #{quantity} #{model.name}", user_id)
    order_lines << o
  end
  
  def update_line(line_id, required_quantity, user_id)
    line = order_lines.find(line_id)
    original = line.quantity
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
  
  private
  
  def max_available
    10 #TODO: When we have reservations and stuff
  end
  
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
