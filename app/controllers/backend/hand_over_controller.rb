class Backend::HandOverController < Backend::BackendController

  before_filter :load_contract, :only => [:add_line, :swap_model_line, :time_lines, :remove_lines]

  def index
    
#old#    @grouped_lines = []

    if params[:search]
      params[:search] = "*#{params[:search]}*" # search with partial string
      @contracts = Contract.find_by_contents(params[:search], {}, {:conditions => ["status_const = ?", Contract::NEW]})

#old#      
#      @contracts.each do |c|
#        dates = c.lines.collect { |l| l.start_date }.uniq
#        dates.each { |d| e = Contract.new(c.attributes); e.lines << c.lines; @grouped_lines << e.visits(d) }
#      end

      # OPTIMIZE named_scope intersection?
      @visits = current_inventory_pool.hand_over_visits.select {|v| v.contract_lines.any? {|l| @contracts.include?(l.contract) } }

  elsif params[:user_id]
      @user = User.find(params[:user_id])

#old#    
#      #@grouped_lines = ContractLine.ready_for_hand_over(@user)
#      @contracts = [@user.current_contract(current_inventory_pool)]
#      @contracts.each do |c|
#        dates = c.lines.collect { |l| l.start_date }.uniq
#        dates.each { |d| e = Contract.new(c.attributes); e.lines << c.lines; @grouped_lines << e.visits(d) }
#      end

      # OPTIMIZE named_scope intersection?
      @visits = current_inventory_pool.hand_over_visits.select {|v| v.user == @user}
      
    else
#      @grouped_lines = ContractLine.ready_for_hand_over                                           
#      @contracts = Contract.new_contracts.to_hand_over
#old#      @contracts = Contract.ready_for_hand_over

#old#      @contracts = current_inventory_pool.contracts.ready_for_hand_over
#old#      @grouped_lines = [] 
#old#      @contracts.each { |c| @grouped_lines << c.visits(c.s.to_date) }
      
      @visits = current_inventory_pool.hand_over_visits
    end
    
    render :partial => 'visits' if request.post? # TODO lines or contracts or visits                                          
  end

  # get current open contract for a given user
  def show
    user = User.find(params[:id])
    @contract = user.get_current_contract(current_inventory_pool)
    @contract.contract_lines.sort!
  end
  
  # Creating the definitive contract
  def sign_contract
    if request.post?
      @contract = Contract.find(params[:id])
      @lines = @contract.contract_lines.find(params[:lines]) unless params[:lines].nil?
      @contract.sign(@lines)

      # TODO generate contract
      send_data @contract.printouts.last.pdf, :filename => "contract.pdf", :type => "application/pdf"

#      redirect_to :action => 'index'

    else
      #@user = User.find(params[:id])
      #@lines = @user.get_signed_contract_lines.find(params[:lines].split(','))
      @lines = ContractLine.find(params[:lines].split(','))
      @lines = @lines.delete_if {|l| l.item.nil? }
      render :layout => $modal_layout_path
    end    
  end

  # Changes the line according to the inserted inventory code
  def change_line
    if request.post?
      # TODO refactor in the Contract model and keep track of changes

      @contract_line = ContractLine.find(params[:contract_line_id])
      @contract = @contract_line.contract
      
      required_item_inventory_code = params[:code]
      @contract_line.item = Item.find(:first, :conditions => { :inventory_code => required_item_inventory_code})
      @contract_line.start_date = Date.today
      if @contract_line.save
        #change = _("Changed dates for %{model} from %{from} to %{to}") % { :model => line.model.name, :from => "#{original_start_date} - #{original_end_date}", :to => "#{line.start_date} - #{line.end_date}" }
        #log_change(change, user_id)
      else
        @contract_line.errors.each_full do |msg|
          @contract.errors.add_to_base msg
        end
      end
      
    end
  end  

  # given an inventory_code, searches for a matching contract_line
  def assign_inventory_code
    if request.post?
      item = Item.find(:first, :conditions => { :inventory_code => params[:code] })
      model = item.model unless item.nil?
      unless model.nil?
        contract = Contract.find(params[:id])
        contract_line = contract.contract_lines.find(:first,
                                                     :conditions => { :model_id => model.id,
                                                                      :item_id => nil })
        unless contract_line.nil?
          params[:contract_line_id] = contract_line.id.to_s
          change_line
        end
      end
      render :action => 'change_line'
    end
  end

  
  def add_line
    generic_add_line(@contract, @contract.user.id)
  end

  def swap_model_line
    generic_swap_model_line(@contract, @contract.user.id)
  end

  def time_lines
    generic_time_lines(@contract, @contract.user.id)
  end    

  # remove a contract line for a given contract
  def remove_lines
    generic_remove_lines(@contract, @contract.user.id)
  end  


  private
  
  def load_contract
    @contract = Contract.find(params[:id]) if params[:id]
  end


end
