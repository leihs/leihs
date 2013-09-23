After('@javascript') do |scenario|
  page.execute_script("window.close()")
end