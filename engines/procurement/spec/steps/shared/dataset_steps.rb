module DatasetSteps

  step 'the basic dataset is ready' do
    step 'a procurement admin exists'
    step 'the current budget period exist'
    step 'there exists a procurement group'
    step 'there exist 3 requesters'
  end

  ######################################################

  step 'a procurement admin exists' do
    Procurement::Access.admins.exists? \
      || FactoryGirl.create(:procurement_access, :admin)
  end

  step 'there exist :count requesters' do |count|
    count.to_i.times do
      FactoryGirl.create(:procurement_access, :requester)
    end
  end

  step 'there exists a procurement group' do
    @group = Procurement::Group.first || FactoryGirl.create(:procurement_group)
  end

  step 'the current budget period exist' do
    @budget_period = FactoryGirl.create(:procurement_budget_period)
  end

end
