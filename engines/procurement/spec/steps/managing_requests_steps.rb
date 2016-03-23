require_relative 'shared/common_steps'
require_relative 'shared/dataset_steps'
require_relative 'shared/filter_steps'
require_relative 'shared/navigation_steps'
require_relative 'shared/personas_steps'

steps_for :managing_requests do
  include CommonSteps
  include DatasetSteps
  include FilterSteps
  include NavigationSteps
  include PersonasSteps

  step 'a new request line is added' do
    find '.request[data-request_id="new_request"]', visible: true
  end

  step 'a request containing a template article exists' do
    template_category = FactoryGirl.create :procurement_template_category,
                                           group: @group
    @template = FactoryGirl.create :procurement_template,
                                   template_category: template_category
    @request = FactoryGirl.create :procurement_request,
                                  user: @current_user,
                                  group: @group,
                                  template: @template

  end

  step 'all fields turn white' do
    within '.request[data-request_id="new_request"]' do
      all('input', minimum: 1).each do |el|
        color = el.native.css_value('background-color')
        next if el[:type] == 'file'
        expect(color).to eq 'rgba(255, 255, 255, 1)'
      end
    end
  end

  step 'an email for a group exists' do
    @group = FactoryGirl.create :procurement_group,
                                email: Faker::Internet.email
  end

  step 'each template article contains' do |table|
    table.raw.flatten.each do |value|
      key = case value
            when 'Article nr. / Producer nr.'
                :article_number
            when 'Item price'
                :price
            when 'Supplier'
                :supplier_name
            else
                raise
            end
      Procurement::Template.all.each do |template|
        expect(template.send key).to be
      end
    end
  end

  step 'I am navigated to the request containing this template article' do
    find ".request[data-request_id='#{@request.id}']" \
         "[data-template_id='#{@request.template_id}']",
         visible: true
  end

  step 'I can change the budget period of my request' do
    request = get_current_request @current_user
    visit_request(request)
    next_budget_period = Procurement::BudgetPeriod\
        .where('end_date > ?', request.budget_period.end_date).first

    within ".request[data-request_id='#{request.id}']" do
      link_on_dropdown(next_budget_period.name).click
    end

    expect(page).to have_content _('Request moved')
    expect(request.reload.budget_period_id).to be next_budget_period.id
  end

  step 'I can change the procurement group of my request' do
    request = get_current_request @current_user
    visit_request(request)
    other_group = Procurement::Group.where.not(id: request.group_id).first

    within ".request[data-request_id='#{request.id}']" do
      link_on_dropdown(other_group.name).click
    end

    expect(page).to have_content _('Request moved')
    expect(request.reload.group_id).to be other_group.id
  end

  step 'I can delete my request' do
    @request = get_current_request @current_user
    visit_request(@request)

    step 'I delete the request'

    expect(page).to have_content _('Deleted')
    expect { @request.reload }.to raise_error ActiveRecord::RecordNotFound
  end

  step 'I can modify my request' do
    request = get_current_request @current_user
    visit_request(request)

    text = Faker::Lorem.sentence
    within ".request[data-request_id='#{request.id}']" do
      fill_in _('Motivation'), with: text
    end

    step 'I click on save'
    step 'I see a success message'
    expect(request.reload.motivation).to eq text
  end

  step 'I choose the article from the suggested list' do
    find('.ui-autocomplete .ui-menu-item a', text: @model.to_s).click
  end

  step 'I search :boolean model by typing the article name' do |boolean|
    @text = if boolean
              @model = Model.order('RAND()').first
              expect(@model).to be
              @model.to_s[0, 4]
            else
              Faker::Lorem.sentence
            end

    within '.request[data-request_id="new_request"]' do
      within '.form-group', text: _('Article / Project') do
        find('input').set @text
      end
    end
  end

  step 'I choose a group' do
    @group ||= Procurement::Group.first.name
    within '.panel-success .panel-body' do
      click_on @group.name
    end
  end

  step 'I choose a template article' do
    @template = @category.templates.sample
    within '.panel-success > .panel-body' do
      within '.panel', text: @category.name do
        find('.list-group-item', text: @template.article_name).click
      end
    end
  end

  step 'I click on choice :choice' do |choice|
    case choice
    when 'yes'
        page.driver.browser.switch_to.alert.accept
    when 'no'
        page.driver.browser.switch_to.alert.dismiss
    else
        raise
    end
  end

  step 'I click on the attachment thumbnail' do
    within '.form-group', text: _('Attachments') do
      within 'ul' do
        @attachment = @request.attachments.first
        within 'li', text: @attachment.file.original_filename do
          find('img').click
        end
      end
    end
  end

  step 'I click on the email icon' do
    # NOTE we don't click to open the mail client, just parsing the mailto link
    within '.panel-success > .panel-heading' do
      @mailto_link = find('.fa-envelope').find(:xpath, 'ancestor::a')[:href]
    end
  end

  step 'I click on the template article which has ' \
       'already been added to the request' do
    within '.sidebar-wrapper' do
      find('.panel-heading', text: @request.template.template_category.name).click
      find('.list-group-item', text: @request.template.article_name).click
    end
  end

  step 'I delete the attachment' do
    within '.form-group', text: _('Attachments') do
      find('.fa-trash', match: :first).click
    end
  end

  step 'I delete the request' do
    within ".request[data-request_id='#{@request.id}']" do
      link_on_dropdown(_('Delete')).click
    end
  end

  step 'I delete this character' do
    @field.set ''
  end

  step 'I do not see the budget limits' do
    within '.panel-success .panel-body' do
      displayed_groups.each do |group|
        within '.row', text: group.name do
          expect(page).to have_no_selector '.budget_limit'
        end
      end
    end
  end

  step 'I do not see the percentage signs' do
    within '.panel-success .panel-body' do
      displayed_groups.each do |group|
        within '.row', text: group.name do
          expect(page).to have_no_selector '.progress-radial'
        end
      end
    end
  end

  step 'I download the attachment' do
    within '.form-group', text: _('Attachments') do
      within 'ul' do
        @attachment = @request.attachments.first
        find('li a', text: @attachment.file.original_filename).click
      end
    end
  end

  step 'I enter the requested amount' do
    within '.request[data-request_id="new_request"]' do
      within '.form-group', text: _('Item price') do
        find('input').set @changes[:price] = Faker::Number.number(4).to_i
      end
      fill_in _('Requested quantity'), with: \
        @changes[:requested_quantity] = Faker::Number.number(2).to_i
    end
  end

  step 'I open the request' do
    find(".list-group-item[data-request_id='#{@request.id}']").click
  end

  step 'I press on a category' do
    @category = Procurement::TemplateCategory.all.sample
    within '.panel-success > .panel-body' do
      find('.panel-heading', text: @category.name).click
    end
  end

  step 'I press on the plus icon of the budget period' do
    within '#filter_target' do
      within '.panel-success > .panel-heading' do
        find('i.fa-plus-circle').click
      end
    end
  end

  step 'I press on the plus icon on the left sidebar' do
    within '.sidebar-wrapper' do
      find('i.fa-plus-circle').click
    end
  end

  step 'I receive a message asking me if I am sure I want to delete the data' do
    # page.driver.browser.switch_to.alert.accept
    page.driver.browser.switch_to.alert
  end

  step 'I see all categories of all groups listed' do
    Procurement::TemplateCategory.all.each do |category|
      within '.panel-success > .panel-body' do
        find '.panel-heading', text: category.name
      end
    end
  end

  step 'I see all template articles of this category' do
    within '.panel-success > .panel-body' do
      within '.panel', text: @category.name do
        @category.templates.each do |template|
          find '.list-group-item', text: template.article_name
        end
      end
    end
  end

  step 'I see the following request information' do |table|
    within ".request[data-request_id='#{@request.id}']" do
      table.raw.flatten.each do |value|
        case value
          # when 'article name'
          #   find '.col-sm-2', text: request.article_name
          # when 'name of the requester'
          #   find '.col-sm-2', text: request.user.to_s
          # when 'department'
          #   find '.col-sm-2', text: request.organization.parent.to_s
          # when 'organisation'
          #   find '.col-sm-2', text: request.organization.to_s
          # when 'price'
          #   find '.col-sm-1 .total_price', text: request.price.to_i
          # when 'requested amount'
          #   within all('.col-sm-2.quantities div', count: 3)[0] do
          #     expect(page).to have_content request.requested_quantity
          #   end
        when 'approved amount'
            within '.form-group', text: _('Approved quantity') do
              find '.label', text: @request.approved_quantity
            end
          # when 'order amount'
          #   within all('.col-sm-2.quantities div', count: 3)[2] do
          #     expect(page).to have_content request.order_quantity
          #   end
          # when 'total amount'
          #   find '.col-sm-1 .total_price',
          #        text: request.total_price(@current_user).to_i
          # when 'priority'
          #   find '.col-sm-1', text: _(request.priority.capitalize)
          # when 'state'
          #   state = request.state(@current_user)
          #   find '.col-sm-1', text: _(state.to_s.humanize)
        when 'inspection comment'
            within '.form-group', text: _('Inspection comment') do
              find 'div', text: @request.inspection_comment
            end
        else
            raise
        end
      end
    end
  end

  step 'I sort the requests by :field' do |field|
    within '#column-titles' do
      label, @key = case field
                    when 'article name'
                        [_('Article / Project'), 'article_name']
                    when 'requester'
                        [_('Requester'), 'user']
                    when 'organisation'
                        [_('Organisation'), 'department']
                    when 'price'
                        [_('Price'), 'price']
                    when 'quantity'
                        [_('Quantities'), 'requested_quantity']
                    when 'the total amount'
                        [_('Total'), 'total_price']
                    when 'priority'
                        [_('Priority'), 'priority']
                    when 'state'
                        [_('State'), 'state']
                    else
                        raise
                    end
      click_on label
    end

    step 'page has been loaded'
  end

  step 'I type the first character in a field of the request form' do
    within ".request[data-request_id='new_request']" do
      @field = find("input[name*='[article_number]']")
      @field.set 'a'
    end
  end

  step 'no search result is found' do
    expect(page).to have_no_selector '.ui-autocomplete'
  end

  step 'only my requests are shown' do
    elements = all('[data-request_id]', minimum: 1)
    expect(elements).not_to be_empty
    elements.each do |element|
      request = Procurement::Request.find element['data-request_id']
      expect(request.user_id).to eq @current_user.id
    end
  end

  step 'no information is saved to the database' do
    expect(Procurement::Request.all).to be_empty
  end

  step 'no option is chosen yet for the field Replacement / New' do
    label = format('%s / %s', _('Replacement'), _('New'))
    within '.form-group', text: label do
      expect(page).to have_no_selector "input[type='radio']:checked"
    end
  end

  step 'no requests exist' do
    Procurement::Request.destroy_all
    expect(Procurement::Request.count).to be_zero
  end

  step 'several models exist' do
    5.times do
      FactoryGirl.create(:model)
    end
  end

  step 'several points of delivery exist' do
    5.times do
      FactoryGirl.create :location
    end
  end

  step 'several receivers exist' do
    5.times do
      step 'a receiver exists'
    end
  end

  step 'the amount and the price are multiplied and the result is shown' do
    within '.request[data-request_id="new_request"]' do
      total = @changes[:price] * (@changes[:order_quantity] || \
                                  @changes[:approved_quantity] || \
                                  @changes[:requested_quantity])
      expect(find('.label.label-primary.total_price').text).to eq currency(total)
    end
  end

  step 'the amount of requests found is shown' do
    step \
      format('I see the amount of requests which are listed is %d',
             @found_requests.count)
  end

  step 'the attachment is deleted successfully from the database' do
    expect(@request.reload.attachments).to be_empty
  end

  step 'the content of the file is shown in a viewer' do
    new_window = page.driver.browser.window_handles.last
    page.driver.browser.switch_to.window new_window
    expect(current_path).to match /#{@attachment.file.original_filename}$/
  end

  step 'the current date has not yet reached the inspection start date' do
    travel_to_date Procurement::BudgetPeriod.current.inspection_start_date - 1.day
    expect(Time.zone.today).to be < \
      Procurement::BudgetPeriod.current.inspection_start_date
  end

  step 'the data is shown in the according sort order' do
    client_ids = all('[data-request_id]', minimum: 1).map do |el|
      el['data-request_id'].to_i
    end

    server_ids = Procurement::Request.where(id: client_ids).sort do |a, b|
      case @key
      when 'total_price'
          a.total_price(@current_user) <=> b.total_price(@current_user)
      when 'state'
          Procurement::Request::STATES.index(a.state(@current_user)) <=> \
                Procurement::Request::STATES.index(b.state(@current_user))
      when 'department'
          a.organization.parent.to_s.downcase <=> \
                b.organization.parent.to_s.downcase
      when 'article_name', 'user'
          a.send(@key).to_s.downcase <=> b.send(@key).to_s.downcase
      else
          a.send(@key) <=> b.send(@key)
      end
    end.map &:id

    # NOTE the default sort is on state, then the first click sorts descending
    server_ids.reverse! if @key == 'state'

    expect(client_ids).to eq server_ids
  end

  step 'the entered article name is saved' do
    @changes[:article_name] = @text
    step 'I see a success message'
    step 'the request with all given information ' \
         'was created successfully in the database'
  end

  step 'the :field value :value is set by default' do |field, value|
    within '.request[data-request_id="new_request"]' do
      label = case field
              when 'priority'
                  _('Priority')
                # when 'replacement'
                #   "%s / %s" % [_('Replacement'), _('New')]
              else
                  raise
              end
      within '.form-group', text: label do
        within 'label', text: /^#{_(value)}$/ do
          find("input[type='radio']:checked")
        end
      end
    end
  end

  step 'the field where I have typed the character is not marked red' do
    color = @field.native.css_value('background-color')
    expect(color).not_to eq 'rgba(242, 222, 222, 1)'
  end

  step 'the file is downloaded' do
    expect(page.driver.browser.switch_to.active_element.text).to eq \
      @attachment.file.original_filename
  end

  step 'the following fields are mandatory and marked red' do |table|
    table.raw.flatten.each do |key|
      step format('the field "%s" is marked red', key)
    end
  end

  step 'the following template data are :string_with_spaces' \
    do |string_with_spaces, table|
    within ".request[data-template_id='#{@template.id}']" do
      table.raw.flatten.each do |value|
        within '.form-group', text: _(value) do
          case string_with_spaces
          when 'prefilled'
              expect(find('input').value).to eq \
                case value
                when 'Article / Project'
                    @template.article_name
                when 'Article nr. / Producer nr.'
                    @template.article_number
                when 'Item price'
                    @template.price.to_i.to_s
                when 'Supplier'
                    @template.supplier_name
                else
                    raise
                end
          when 'displayed as read-only'
              expect(page).to have_content \
                case value
                when 'Article / Project'
                   @template.article_name
                when 'Article nr. / Producer nr.'
                   @template.article_number
                when 'Item price'
                   currency @template.price.to_i
                when 'Supplier'
                   @template.supplier_name
                else
                   raise
                end
          end
        end
      end
    end
  end

  step 'the line is deleted' do
    find '.request[data-request_id="new_request"]', visible: false
  end

  step 'the list of requests is adjusted immediately ' \
       'according to the filters chosen' do
    step 'page has been loaded'
    within '#filter_target' do
      @found_requests = Procurement::Request.search(@filter[:search]).where(
        user_id: @current_user,
        budget_period_id: @filter[:budget_period_ids],
        group_id: @filter[:group_ids],
        priority: @filter[:priorities]
      ).select do |r|
        @filter[:states].map(&:to_sym).include? r.state(@current_user)
      end
      all('[data-request_id]', minimum: 1).map do |el|
        el['data-request_id']
      end.each do |id|
        expect(@found_requests.map(&:id)).to include id.to_i
      end
    end
  end

  step 'the email program is opened' do
    # NOTE we don't click to open the mail client, just parsing the mailto link
  end

  step 'the model name is copied into the article name field' do
    within '.request[data-request_id="new_request"]' do
      within '.form-group', text: _('Article / Project') do
        expect(find('input').value).to eq @model.to_s
      end
    end
  end

  step 'the receiver of the email is the email of the group' do
    expect(@mailto_link.match(/mailto:(.*)\?.*/)[1]).to eq @group.email
  end
  step 'the subject of the email is :subject' do |subject|
    expect(@mailto_link.match(/.*subject=(.*)\(.*/)[1].gsub('%20', ' ').strip).to \
      eq subject
  end
  step 'the group name is placed in paranthesis at the end of the subject' do
    expect(@mailto_link.match(/.*subject=.*\((.*)\)/)[1].gsub('%20', ' ')).to \
      eq @group.name
  end

  step 'the request includes an :string_with_spaces' do |string_with_spaces|
    file_path = case string_with_spaces
                when 'attachment'
                    'features/data/LDAP_generic.yml'
                when 'attachment with the attribute .jpg'
                    'features/data/images/image1.jpg'
                when 'attachment with the attribute .pdf'
                    'features/data/test.pdf'
                else
                    raise
                end
    @request.update_attributes(attachments_attributes:
                                   [{ file: File.open(file_path) }])
  end

  step 'the request is :result in the database' do |result|
    case result
    when 'successfully deleted'
        step 'I see a success message'
        expect { @request.reload }.to raise_error ActiveRecord::RecordNotFound
    when 'not deleted'
        expect(@request.reload).not_to be_nil
    else
        raise
    end
  end

  step 'the template article contains an articlenr./suppliernr.' do
    if @template.article_number.empty?
      @template.update_attributes(article_number: Faker::Lorem.word)
    end
  end

  step 'the template id is nullified in the database' do
    expect(@request.reload.template).to be_nil
  end

  private

  def get_current_request(user)
    Procurement::Request.find_by \
      user_id: user.id,
      budget_period_id: Procurement::BudgetPeriod.current
  end

end
