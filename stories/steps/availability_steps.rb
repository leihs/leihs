steps_for(:availability) do
  
  
  Given "a model '$model' exists" do | model |
    @model = Factory.create_model(:name => model)
  end
  
  Given "$number items of model '$model' exist" do |number, model|
    number.to_i.times do | i |
      Factory.create_item(:model_id => Model.find_by_name(model).id)
    end
  end
  
  Given "$number reservations exist for model '$model'" do |number, model|
  end
  
  Given "a reservation exists for $quantity '$model' from $from to $to" do |quantity, model, from, to|
    model = Model.find_by_name(model)
    order = Factory.create_order
    order.add_line(quantity.to_i, model, nil, Factory.parsedate(from), Factory.parsedate(to))
    order.submit
    order.save
    order.order_lines.size.should >= 1
    OrderLine.current_and_future_reservations(model.id).size.should >= 1
  end
  
  Given "the maintenance period for this model is $days days" do |days|
    @model.maintenance_period = days.to_i
    @model.save
  end

  Given "$who marks $quantity '$model' as 'in-repair' on 18.3.2100" do |who, quantity, model|
    @model = Model.find_by_name(model)
    quantity.to_i.times do |i|
      @model.items[i].status = Item::IN_REPAIR
      @model.items[i].save
    end
  end
  
  When "$who checks availability for '$what'" do |who, model|
    @periods = @model.availability
  end
  
  When "$who checks availability for '$what' on $date" do |who, model, date|
    date = Factory.parsedate(date)
    @periods = @model.availability(nil, date)
  end
  
  When "the date is $date and the item isn't returned" do |date|
    date = Factory.parsedate(date)
    
  end
	
	Then "it should always be available" do
	  @periods.size.should == 1
	  @periods[0].start_date.should <= Date.today
    @periods[0].forever?.should == true
  end
	
	Then "$quantity should be available from $from to $to" do |quantity, from, to|
	  from = ("now" == from) ? Date.today : Factory.parsedate(from)
    to = ("the_end_of_time" == to) ? to = nil : to = Factory.parsedate(to)
  
    period = get_period(from, to, @periods)
    if period.nil?
      puts ""
      puts "Searching: #{from.day}.#{from.month}.#{from.year} - #{to.day}.#{to.month}.#{to.year}"
      @periods.each do |p|
        puts "   -> #{p.start_date.day}.#{p.start_date.month}.#{p.start_date.year} - #{p.end_date.day}.#{p.end_date.month}.#{p.end_date.year}" unless p.end_date.nil?
      end
    end
    period.should_not be_nil
    
    period.quantity.should == quantity.to_i
	end
  
  Then "the maximum available quantity on $date is $quantity" do |date, quantity|
    @model.maximum_available(Factory.parsedate(date)).should == quantity.to_i
  end
  
  Then "the maximum available quantity from $start_date to $end_date is $quantity" do |start_date, end_date, quantity|
    @model.maximum_available_in_period(Factory.parsedate(start_date), Factory.parsedate(end_date)).should == quantity.to_i
  end
  
  
end