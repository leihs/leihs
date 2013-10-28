# -*- encoding : utf-8 -*-

Angenommen(/^ich habe eine offene Bestellung mit Modellen$/) do
  FactoryGirl.create(:contract_with_lines, inventory_pool: @current_user.inventory_pools.sample, user: @current_user, status: :unsubmitted, lines_count: rand(3..10))
end

Angenommen(/^die Bestellung Timeout ist (\d+) Minuten$/) do |arg1|
  Contract::TIMEOUT_MINUTES.should == arg1.to_i
end

#######################################################################

Wenn(/^ich ein Modell der Bestellung hinzufüge$/) do
  @inventory_pool = @current_user.inventory_pools.find_by_name("A-Ausleihe")
  @current_user.get_unsubmitted_contract(@inventory_pool).contract_lines << (@new_contract_line = FactoryGirl.create(:contract_line, :contract => @current_user.get_unsubmitted_contract(@inventory_pool)))
  @new_contract_line.reload.available?.should be_true
end

Wenn(/^ich dasselbe Modell einer Bestellung hinzufüge$/) do
  contract = @inventory_pool.contracts.submitted.all.sample
  (@new_contract_line.maximum_available_quantity + 1).times do
    contract.contract_lines << FactoryGirl.create(:contract_line,
                                                  :contract => contract,
                                                  :start_date => @new_contract_line.start_date,
                                                  :end_date => @new_contract_line.end_date,
                                                  :model_id => @new_contract_line.model_id)
  end
end

Wenn(/^die maximale Anzahl der Gegenstände überschritten ist$/) do
  @new_contract_line.reload.available?.should be_false
end

Dann(/^wird die Bestellung nicht abgeschlossen$/) do
  @current_user.contracts.unsubmitted.each do |contract|
    contract.status.should == :unsubmitted
  end
end

Dann(/^ich erhalte eine Fehlermeldung$/) do
  first(".error")
end

#######################################################################

Wenn(/^ich länger als (\d+) Minuten keine Aktivität ausgeführt habe$/) do |arg1|
  @current_user.contracts.unsubmitted.each do |contract|
    contract.update_attributes updated_at: Time.now - (arg1.to_i + 1).minutes if (Time.now - contract.updated_at) <= arg1.to_i.minutes
  end
end

Angenommen(/^ein Modell ist nicht verfügbar$/) do
  line = @current_user.contracts.unsubmitted.flat_map(&:lines).sample
  (line.maximum_available_quantity + 1).times do
    c = FactoryGirl.create(:contract,
                           :inventory_pool => line.inventory_pool)
    FactoryGirl.create(:contract_line,
                       :contract => c,
                       :model => line.model,
                       :start_date => line.start_date,
                       :end_date => line.end_date)
  end
  line.reload.available?.should be_false
end

Angenommen(/^(\d+) Modelle sind nicht verfügbar$/) do |n|
  @current_user.contracts.unsubmitted.flat_map(&:lines).take(n.to_i).each do |line|
    (line.maximum_available_quantity + 1).times do
      c = FactoryGirl.create(:contract,
                             :inventory_pool => line.inventory_pool)
      FactoryGirl.create(:contract_line,
                         :contract => c,
                         :model => line.model,
                         :start_date => line.start_date,
                         :end_date => line.end_date)
    end
  end
  @current_user.contracts.unsubmitted.flat_map(&:lines).select{|line| not line.available?}.length.should == n.to_i
end

Wenn(/^ich eine Aktivität ausführe$/) do
  visit borrow_root_path
end

Dann(/^werde ich auf die Timeout Page geleitet$/) do
  current_path.should == borrow_order_timed_out_path
end

#######################################################################

Dann(/^werden die Modelle meiner Bestellung freigegeben$/) do
  @current_user.contracts.unsubmitted.flat_map(&:lines).all? do |line|
    not line.inventory_pool.running_lines.exists? type: "OrderLine", id: line.id
  end.should be_true
end

Dann(/^bleiben die Modelle in der Bestellung blockiert$/) do
  @current_user.get_unsubmitted_contract.lines.all? do |line|
    line.inventory_pool.running_lines.exists? type: "OrderLine", id: line.id
  end.should be_true
end

#######################################################################

Angenommen(/^alle Modelle verfügbar sind$/) do
  @current_user.get_unsubmitted_contract.lines.all? {|line| line.available? }.should be_true
end

Dann(/^kann man sein Prozess fortsetzen$/) do
  current_path.should == borrow_root_path
end

Dann(/^die Modelle werden blockiert$/) do
  step "bleiben die Modelle in der Bestellung blockiert"
end

