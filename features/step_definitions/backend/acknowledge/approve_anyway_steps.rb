Given /^I try to approve a contract that has problems$/ do
  @unapprovable_contract =  @ip.contracts.submitted.detect{|o| not o.approvable?}
  find(".toggle .text").click
  find(".contract.line[data-id='#{@unapprovable_contract.id}'] .actions .button", :text => _("Approve")).click
  find(".dialog")
end

Then /^I got an information that this contract has problems$/ do
  find(".dialog .flash_message.visible")
end

When /^I approve anyway$/ do
  find(".dialog .navigation .alternatives .trigger").hover
  find(".dialog .navigation .button[name='force']").click
  page.has_no_selector?(".dialog")
end

Then /^this contract is approved$/ do
  @unapprovable_contract.reload.status.should == :approved
  page.has_no_selector?(".contract.line[data-id='#{@unapprovable_contract.id}']")
end
