module PersonasSteps
  # procurement admin
  step 'I am Hans Ueli' do
    persona = create_persona('Hans Ueli')
    FactoryGirl.create(:procurement_access, :admin, user: persona)
    login_as persona
  end

  # requester
  step 'I am Roger' do
    persona = create_persona('Roger')
    FactoryGirl.create(:procurement_access, :requester, user: persona)
    login_as persona
  end

  # inspector and requester
  step 'I am Barbara' do
    persona = create_persona('Barbara')
    @group = FactoryGirl.create(:procurement_group_inspector, user: persona).group
    FactoryGirl.create(:procurement_access, :requester, user: persona)
    login_as persona
    step 'I am inspector of this group'
  end

  # inspector
  step 'I am Anna' do
    persona = create_persona('Anna')
    @group = FactoryGirl.create(:procurement_group_inspector, user: persona).group
    login_as persona
    step 'I am inspector of this group'
  end

  # leihs admin
  step 'I am Gino' do
    persona = create_persona('Gino')
    FactoryGirl.create(:access_right, role: :admin, user: persona)
    login_as persona
  end

  step 'I am inspector of this group' do
    expect(@group.inspectable_by?(@current_user)).to be true
  end

  step 'several admin users exist' do
    Procurement::Access.admins.count >= 3 \
      || 3.times { FactoryGirl.create(:procurement_access, :admin) }
  end

  step 'there exists a requester' do
    @user = find_or_create_user(Faker::Name.first_name)
    FactoryGirl.create(:procurement_access, :requester, user: @user)
  end

  def find_or_create_user(firstname, as_requester = false)
    user = ::User.find_by(firstname: firstname) || \
      begin
        new_user = FactoryGirl.create(:user, firstname: firstname)
        FactoryGirl.create(:access_right,
                           user: new_user,
                           inventory_pool: FactoryGirl.create(:inventory_pool))
        new_user
    end
    if as_requester and Procurement::Access.requesters.find_by(user_id: user).nil?
      FactoryGirl.create :procurement_access, :requester, user: user
    end
    user
  end

  private

  def set_locale(user)
    FastGettext.locale = user.language.locale_name.tr('-', '_')
  end

  def create_persona(firstname)
    user = find_or_create_user(firstname)
    set_locale(user)
    user
  end

  def login_as(user)
    @current_user = user
    visit '/authenticator/db/login'
    fill_in _('Username'), with: user.login
    fill_in _('Password'), with: 'password'
    click_on 'Login'
    expect(page).to have_content user.short_name
  end
end
