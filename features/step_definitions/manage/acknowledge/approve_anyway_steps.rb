Given /^I try to approve a contract that has problems$/ do
  @unapprovable_contract =  @ip.contracts.submitted.shuffle.detect{|o| not o.approvable?}
  find("[data-collapsed-toggle='#open-orders']").click unless all("[data-collapsed-toggle='#open-orders']").empty?
  within(".line[data-id='#{@unapprovable_contract.id}']") do
    find("[data-order-approve]", :text => _("Approve")).click
  end
  find(".modal")
end

Then /^I got an information that this contract has problems$/ do
  find(".modal .row.emboss.red")
end

When /^I approve anyway$/ do
  within(".modal") do
    find(".dropdown-toggle").hover
    find(".dropdown-item[data-approve-anyway]").click
  end
  page.has_no_selector?(".modal")
end

Then /^this contract is approved$/ do
  step "ensure there are no active requests"
  page.has_no_selector?(".contract.line[data-id='#{@unapprovable_contract.id}']")
  @unapprovable_contract.reload.status.should == :approved
end
