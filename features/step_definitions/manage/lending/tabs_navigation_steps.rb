Then /^I can navigate all navigation items and nested tabs$/ do
  texts = all("#navigation .item a").map{|x| x.text}
  texts.shift
  texts.each do |text|
    find_link(text).click
    page.should have_selector(".inlinetabs .tab")
    tab_texts = all(".inlinetabs .tab").map{|x| x.text}
    tab_texts.each do |tab_text|
      find(".tab", :text => tab_text, :match => :prefer_exact).click
      find(".inlinetabs .tab.active").text[tab_text].should be
    end
  end
  sleep(0.66)
end
