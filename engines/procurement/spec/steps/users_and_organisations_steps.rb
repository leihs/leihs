require_relative 'shared/common_steps'
require_relative 'shared/dataset_steps'
require_relative 'shared/navigation_steps'
require_relative 'shared/personas_steps'

steps_for :users_and_organisations do
  include CommonSteps
  include DatasetSteps
  include NavigationSteps
  include PersonasSteps

  step 'I am already an admin' do
    expect(Procurement::Access.admin?(@current_user)).to be true
  end

  step 'there does not exist any requester yet' do
    expect(Procurement::Access.requesters.count).to eq 0
  end

  step 'there is an empty requester line for creating a new one' do
    line = find('table tbody tr')
    line.all('input', minimum: 1).each { |i| expect(i.value).to be_blank }
  end

  step 'there exists a user to become a requester' do
    @user = find_or_create_user(Faker::Name.first_name)
  end

  step 'I fill in the requester name' do
    line = find('table tbody tr')
    line.find("input[name*='name']").set(@user.name)
    find('.ui-autocomplete .ui-menu-item a').click
  end

  step 'I fill in the department' do
    line = find('form table tbody tr')
    line.find("input[name*='department']").set Faker::Lorem.word
  end

  step 'I fill in the organization' do
    line = find('form table tbody tr')
    line.find("input[name*='organization']").set Faker::Lorem.word
  end

  step 'the new requester was created in the database' do
    requester = Procurement::Access.requesters.find_by_user_id @user.id
    expect(requester).to be
  end

  step 'the new requester has not been created' do
    requester = Procurement::Access.requesters.find_by_user_id @user.id
    expect(requester).not_to be
  end

  step 'I click on the minus button on the requester line' do
    within 'form table tbody' do
      within "tr td:first-child input[value='#{@user.name}']" do
        find(:xpath, '../..').find('.fa-minus-circle').click
      end
    end
  end

  step 'the requester line is marked for deletion' do
    within 'form table tbody' do
      find("tr.bg-danger td:first-child input[value='#{@user.name}']")
    end
  end

  step 'the requester disappears from the list' do
    expect(first('form table tbody tr td:first-child input', text: @user.name))
      .not_to be
  end

  step 'the requester was successfully deleted from the database' do
    expect(Procurement::Access.find_by_user_id(@user.id)).not_to be
  end

  step 'I modify the requester name to be that of the extra user' do
    line = find_requester_line(@user.name)
    line.find("input[name*='name']").set(@extra_user.name)
    find('.ui-autocomplete .ui-menu-item a').click
  end

  step 'I modify the department' do
    line = find_requester_line(@user.name)
    @new_department = Faker::Lorem.word
    line.find("input[name*='department']").set @new_department
  end

  step 'I modify the organization' do
    line = find_requester_line(@user.name)
    @new_organization = Faker::Lorem.word
    line.find("input[name*='organization']").set @new_organization
  end

  step 'there exists an extra user' do
    @extra_user = find_or_create_user(Faker::Name.first_name)
  end

  step 'I see the successful changes on the page' do
    expect { find_requester_line(@user.name) }
      .to raise_error Capybara::ElementNotFound
    line = find_requester_line(@extra_user.name)
    expect(line.find("input[name*='department']").value)
      .to eq @new_department
    expect(line.find("input[name*='organization']").value)
      .to eq @new_organization
  end

  step 'the requester information was changed successfully in the database' do
    expect(Procurement::Access.find_by_user_id(@user.id)).not_to be
    access = Procurement::Access.find_by_user_id(@extra_user.id)
    expect(access.organization.name).to eq @new_organization
    dep = Procurement::Organization.find_by_name(@new_department)
    expect(dep).to be
    expect(dep.children).to \
      include Procurement::Organization.find_by_name(@new_organization)
  end

  step 'I can add an admin' do
    admin_ids = Procurement::Access.admins.pluck(:user_id)
    @user = User.not_as_delegations.where.not(id: admin_ids).first \
            || FactoryGirl.create(:user)
    find('.token-input-list .token-input-input-token input#token-input-')
      .set @user.name
    within '.token-input-dropdown' do
      find('li', text: @user.name).click
    end
  end

  step 'I can add the first admin' do
    expect(Procurement::Access.admins).to be_empty
    step 'I can add an admin'
  end

  step 'the new admin was saved to the database' do
    expect(Procurement::Access.admins.exists?(@user.id)).to be true
  end

  step 'the requesters are sorted 0-10 and a-z' do
    within '.panel', text: _('Requesters') do
      texts = all('input[name="requesters[][name]"]', minimum: 1).map &:value
      expect(texts).to eq texts.sort
      expect(texts.count).to be Procurement::Access.requesters.count
    end
  end

  step 'the admins are sorted alphabetically from a-z' do
    texts = all('.token-input-list .token-input-token', minimum: 1).map &:text
    expect(texts).to eq texts.sort
    expect(texts.count).to be Procurement::Access.admins.count
  end

  # step 'a admin user exists' do
  #   # FactoryGirl.create(:procurement_access, :admin)
  #
  #   @admin = Procurement::Access.admins \
  #     # .where.not(user_id: @current_user)
  #     .order('RAND()').first.user
  # end

  step 'I can delete an admin' do
    @admin = Procurement::Access.admins \
              .where.not(user_id: @current_user).first.user
    step 'I can delete the admin'
  end

  step 'I can delete the admin' do
    find('.token-input-list .token-input-token', text: @admin.name)
      .find('.token-input-delete-token').click
  end

  step 'the admin is deleted from the database' do
    expect(Procurement::Access.admins.exists?(@admin.id)).to be false
  end

  step 'organisations exist' do
    step 'there exist 10 requesters'
    expect(Procurement::Organization.exists?).to be true
  end

  step 'I see the organisation tree according ' \
       'to the organisations assigned to requester' do
    Procurement::Access.requesters.each do |requester|
      find('li', text: requester.organization.parent.name)
        .find('li', text: requester.organization.name)
        .find('li', text: requester.user.name)
    end
  end

  step 'the organisation tree shows the departments with its organisation units' do
    Procurement::Organization.roots.each do |organization|
      within('li', text: organization.name) do
        organization.children.each do |child|
          find('li', text: child.name)
        end
      end
    end
  end

  step 'the departments are sorted from 0-10 and a-z' do
    @roots = all('article .container-fluid > ul > li', minimum: 1)
    texts = @roots.map { |x| x.find(:xpath, './b').text }
    expect(texts).to eq texts.sort
  end

  step 'inside the departments the organisations are sorted from 0-10 and a-z' do
    @roots.each do |root|
      texts = root.all(:xpath, './ul/li/b', minimum: 1).map &:text
      expect(texts).to eq texts.sort
    end
  end

  private

  def find_requester_line(name)
    find(:xpath, "//input[@value='#{name}']/ancestor::tr")
  end
end
