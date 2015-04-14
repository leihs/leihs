Then(/^the default (.*) exists in the file system in (.*) as (.*)$/) do |template_name, directory, file_name|
  template = File.join(Rails.root, "app/views/mailer/", directory, file_name)
  expect(File.exists? template).to be true
end

When(/^I specify a mail template for the (.*) action (for the whole system|in the current inventory pool) for each active language$/) do |template_name, scope|
  case scope
    when "for the whole system"
      visit "/manage/mail_templates"
    when "in the current inventory pool"
      visit "/manage/#{@current_inventory_pool.id}/mail_templates"
  end
  find(".list-of-lines .line-col.col3of5", text: /^#{template_name}$/).find(:xpath, "./..").find(".button", text: _("Edit")).click
  step "I land on the mail templates edit page"
end

Then(/^the template (.*) is saved for the (whole system|current inventory pool) for each active language$/) do |template_name, scope|
  inventory_pool_id = case scope
                        when "whole system"
                          nil
                        when "current inventory pool"
                          @current_inventory_pool.id
                      end

  Language.active_languages.each do |language|
    mt = MailTemplate.find_by(inventory_pool_id: inventory_pool_id,
                              name: template_name.gsub(' ', '_'),
                              language: language,
                              format: "text")
    expect(mt).not_to be_nil
  end
end

Given(/^I have a contract with deadline (yesterday|tomorrow)( for the inventory pool "(.*?)")?$/) do |day, arg1, inventory_pool_name|
  @visit = if arg1
             inventory_pool = InventoryPool.find_by(name: inventory_pool_name)
             @current_user.visits.where(inventory_pool_id: inventory_pool)
           else
             @current_user.visits
           end.take_back.order("RAND()").first
  expect(@visit).not_to be_nil

  sign = case day
           when "yesterday"
             :+
           when "tomorrow"
             :-
         end

  Dataset.back_to_date(@visit.date.send(sign, 1.day))
end

Given(/^there (is|is not) a (custom|system\-wide|default) (.*) mail template( for this contract's inventory pool)?( defined for the language "(.*)")?$/) do |arg1, scope, template_name, arg2, arg3, locale_name|
  if scope == "default"
    file = File.join(Rails.root, "app/views/mailer/user/", "#{template_name.gsub(' ', '_')}.text.liquid")
    b = case arg1
          when "is"
            true
          when "is not"
            false
        end
    expect(File.exists? file).to be b
  else
    language = Language.find_by(locale_name: (locale_name || @current_user.language.locale_name))
    inventory_pool_id = case scope
                          when "system-wide"
                            nil
                          when "custom"
                            @visit.inventory_pool_id
                        end
    case arg1
      when "is"
        MailTemplate.find_or_create_by(inventory_pool_id: inventory_pool_id,
                                       name: template_name.gsub(' ', '_'),
                                       language: language,
                                       format: "text") do |x|
          x.body = %Q(Dear {{ user.name }},
                    {{ email_signature }}
                    --
                    #{language.locale_name}
                    --
                    #{Faker::Lorem.sentence}
                    --
                    {{ inventory_pool.name }}
                    {{ inventory_pool.description }}
                    )
        end
      when "is not"
        mt = MailTemplate.find_by(inventory_pool_id: inventory_pool_id,
                                  name: template_name.gsub(' ', '_'),
                                  language: language,
                                  format: "text")
        mt.destroy if mt
    end
  end
end

Given(/^there is a (custom|system\-wide) (.*) mail template( for this contract's inventory pool)? in "(.*?)"$/) do |scope, template_name, arg2, locale_names|
  inventory_pool_id = case scope
                        when "system-wide"
                          nil
                        when "custom"
                          @visit.inventory_pool_id
                      end
  if locale_names == "none"
    expect(MailTemplate.find_by(inventory_pool_id: inventory_pool_id,
                                name: template_name.gsub(' ', '_'),
                                format: "text")).to be_nil
  else
    locale_names.split(',').each do |locale_name|
      language = Language.find_by(locale_name: locale_name)
      MailTemplate.find_or_create_by(inventory_pool_id: inventory_pool_id,
                                     name: template_name.gsub(' ', '_'),
                                     language: language,
                                     format: "text") do |x|
        x.body = %Q(Dear {{ user.name }},
                    {{ email_signature }}
                    --
                    #{language.locale_name}
                    --
                    #{Faker::Lorem.sentence}
                    --
                    {{ inventory_pool.name }}
                    {{ inventory_pool.description }}
                    )
      end
    end
  end
end

When(/^the reminders are sent$/) do
  expect(ActionMailer::Base.deliveries.count).to eq 0
  User.send_deadline_soon_reminder_to_everybody
  User.remind_and_suspend_all
  expect(ActionMailer::Base.deliveries.count).to be > 0
end

Then(/^I receive an email formatted according to the (custom|system\-wide|default) (reminder|deadline soon reminder) mail template$/) do |scope, template_name|
  language = Language.find_by(locale_name: @current_user.language.locale_name)

  sent_mails = ActionMailer::Base.deliveries.select { |m| m.to.include?(@current_user.email) and m.from.include?(@visit.inventory_pool.email) }
  sent_mails = sent_mails.select do |m|
    m.subject == case template_name
                   when "reminder"
                     _('[leihs] Reminder')
                   when "deadline soon reminder"
                     _('[leihs] Some items should be returned tomorrow')
                 end
  end
  expect(sent_mails.size).to eq 1
  sent_mail = sent_mails.first

  template_name = template_name.gsub(' ', '_')
  template = case scope
               when "custom"
                 MailTemplate.find_or_create_by(inventory_pool_id: @visit.inventory_pool_id,
                                                name: template_name,
                                                language: language,
                                                format: "text").body
               when "system-wide"
                 MailTemplate.find_or_create_by(inventory_pool_id: nil,
                                                name: template_name,
                                                language: language,
                                                format: "text").body
               when "default"
                 File.read(File.join(Rails.root, "app/views/mailer/user/", "#{template_name}.text.liquid"))
             end

  variables = MailTemplate.liquid_variables_for_user(@current_user, @visit.inventory_pool, @visit.contract_lines)
  expect(sent_mail.body.to_s).to eq Liquid::Template.parse(template).render(variables)
end

Given(/^the custom (reminder) mail template looks like$/) do |template_name, string|
  language = Language.find_by(locale_name: @current_user.language.locale_name)

  mt = MailTemplate.find_or_initialize_by(inventory_pool_id: @visit.inventory_pool_id,
                                          name: template_name.gsub(' ', '_'),
                                          language: language,
                                          format: "text")
  mt.update_attributes(body: string)
end

def reset_language_for_current_user
  I18n.locale = @current_user.language.locale_name.to_sym
  expect(I18n.locale).to eq @current_user.language.locale_name.to_sym
end

def get_reminder_for_visit(visit)
  reset_language_for_current_user
  sent_mails = ActionMailer::Base.deliveries.select { |m| m.to.include?(@current_user.email) and m.from.include?(visit.inventory_pool.email) }
  sent_mails = sent_mails.select { |m| m.subject == _('[leihs] Reminder') }
  expect(sent_mails.size).to eq 1
  sent_mails.first
end

Then(/^the mail body looks like$/) do |string|
  sent_mail = get_reminder_for_visit(@visit)
  expect(sent_mail.body.to_s).to eq string
end

When(/^my language is set to "(.*?)"$/) do |locale_name|
  language = Language.find_by(locale_name: locale_name)
  @current_user.update_attributes(language: language)
  expect(@current_user.reload.language.locale_name).to eq locale_name
end

When(/^one of my submitted orders to an inventory pool without custom approved mail templates get approved$/) do
  expect(ActionMailer::Base.deliveries.count).to eq 0
  @contract = @current_user.contracts.submitted.detect { |c| c.approvable? and c.inventory_pool.mail_templates.where(name: "approved").empty? }
  @contract.approve(Faker::Lorem.sentence)
  expect(ActionMailer::Base.deliveries.count).to be > 0
end

Then(/^I receive an approved mail based on the system\-wide template for the language "(.*?)"$/) do |locale_name|
  language = Language.find_by(locale_name: locale_name)

  sent_mails = ActionMailer::Base.deliveries.select { |m| m.to.include?(@current_user.email) and m.from.include?(@contract.inventory_pool.email) }
  sent_mails = sent_mails.select { |m| m.subject == _('[leihs] Reservation Confirmation') }
  expect(sent_mails.size).to eq 1
  sent_mail = sent_mails.first

  template = MailTemplate.find_by(inventory_pool_id: nil,
                                  name: "approved",
                                  language: language,
                                  format: "text").body

  variables = MailTemplate.liquid_variables_for_order(@contract)
  expect(sent_mail.body.to_s).to eq Liquid::Template.parse(template).render(variables)
end

Then(/^I receive a (custom|system\-wide|default) (.*) in "(.*?)"$/) do |scope, template_name, locale_names|
  variables = MailTemplate.liquid_variables_for_user(@current_user, @visit.inventory_pool, @visit.contract_lines)
  string = if scope == "default"
             template = File.read(File.join(Rails.root, "app/views/mailer/user/", "#{template_name}.text.liquid"))
             Liquid::Template.parse(template).render(variables)
           else
             inventory_pool_id = case scope
                                   when "system-wide"
                                     nil
                                   when "custom"
                                     @visit.inventory_pool_id
                                 end

             strings = locale_names.split(',').map do |locale_name|
               language = Language.find_by(locale_name: locale_name)
               template = MailTemplate.find_by(inventory_pool_id: inventory_pool_id,
                                               name: template_name.gsub(' ', '_'),
                                               language: language,
                                               format: "text").body
               Liquid::Template.parse(template).render(variables)
             end
             strings.join('\n\n- - - - - - - - - -\n\n')
           end

  sent_mail = get_reminder_for_visit(@visit)
  expect(sent_mail.body.to_s).to eq string
end

When(/^I edit the (reminder) with the "(.*?)" template in "(.*?)"$/) do |template_name, body, locale_name|
  find(".row.margin-vertical-s", text: locale_name).find("textarea[name='mail_templates[][body]']").set body
end

Then(/^I land on the mail templates edit page$/) do
  find("form button[type='submit']", text: _("Save %s") % _("Mail Templates"))
  Language.active_languages.each do |language|
    find("input[name='mail_templates[][language]'][type='hidden'][value='#{language.locale_name}']", visible: false)
  end
end

Then(/^the failing (reminder) mail template in "(.*?)" is highlighted in red$/) do |template_name, locale_name|
  expect(find(".row.margin-vertical-s", text: locale_name).native.css_value('background-color')).to eq "rgba(255, 176, 176, 1)"
end

Then(/^the failing (reminder) mail template in "(.*?)" is not persisted with the "(.*?)" template$/) do |template_name, locale_name, body|
  language = Language.find_by(locale_name: locale_name)
  template = MailTemplate.find_or_initialize_by(inventory_pool_id: @current_inventory_pool.try(:id),
                                                name: template_name.gsub(' ', '_'),
                                                language: language,
                                                format: "text")
  expect(template.body).not_to eq body
end

When(/^I navigate to the mail templates list in the current inventory pool$/) do
  visit "/manage/#{@current_inventory_pool.id}/mail_templates"
end

Then(/^I am redirected to the login page$/) do
  find("h1", text: _("Login"))
  find("form[action='/authenticator/login']")
end

Then(/^I see a list of mail templates$/) do
  find("nav .active", text: _("Mail Templates"))
  find(".list-of-lines")
end
