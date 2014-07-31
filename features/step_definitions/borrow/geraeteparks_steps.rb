# -*- encoding : utf-8 -*-  

Wenn(/^ich den Gerätepark Link drücke$/) do
  visit borrow_root_path
  find("a[href='#{borrow_inventory_pools_path}']", match: :first).click
end

Dann(/^sehe ich die Geräteparks für die ich berechtigt bin$/) do
  @current_user.inventory_pools.each do |ip|
    expect(has_content?(ip.name)).to be true
  end
end

When(/^ich sehe nur die Geräteparks, die ausleihbare Gegenstände enthalten$/) do
  expect(all(".row .padding-inset-l > .row > h2.padding-bottom-s").map(&:text)).to eq @current_user.inventory_pools.with_borrowable_items.sort_by {|ip| ip.name}.map(&:to_s)
end

Dann(/^sehe die Beschreibung für jeden Gerätepark$/) do
  @current_user.inventory_pools.each do |ip|
    ip.description.split(/\n/).each do |text|
      expect(has_content?(text)).to be true
    end
  end
end

Dann(/^die Geräteparks sind auf dieser Seite alphabetisch sortiert$/) do
  expect(all("h2").map(&:text)).to eq all("h2").map(&:text).sort
end
