Then /^I can navigate all navigation items and nested tabs$/ do
  texts = all("#navigation .item a").map{|x| x.text}
  texts.delete_if{|x| x == "Daily View"}
  texts.each do |text|
    find_link(text).click
    wait_until {all("#navigation .item.active").size == 1}
    
    tab_texts = all(".inlinetabs .tab").map{|x| x.text}
    tab_texts.each do |tab_text|
      find(".tab", :text => tab_text).click
      wait_until { all(".inlinetabs .tab.active").size == 1 }
    end
  end
end