require_relative 'shared/common_steps'
require_relative 'shared/navigation_steps'
require_relative 'shared/personas_steps'

steps_for :settings do
  include CommonSteps
  include NavigationSteps
  include PersonasSteps

  step 'a contact form exists' do
    @contact_url = Faker::Internet.url
  end

  step 'I enter the following settings' do |table|
    @settings_key_value = {}
    within 'form table tbody' do
      table.hashes.each do |kv|
        @settings_key_value[kv['key']] = kv['value']
        within 'tr', match: :first do # OPTIMIZE
          find('input[name="settings[][key]"]').set kv['key']
          find('input[name="settings[][value]"]').set kv['value']
        end
      end
    end
  end

  step 'the settings are saved successfully to the database' do
    expect(Procurement::Setting.count).to eq @settings_key_value.count

    @settings_key_value.each_pair do |k, v|
      setting = Procurement::Setting.find_by(key: k, value: v)
      expect(setting).to be
    end
  end

  step 'the contact link is visible' do
    within 'header ul.nav.h4' do
      link = find('a', text: _('Contact'))
      expect(link[:href]).to eq @settings_key_value['contact_url']
    end
  end

end
