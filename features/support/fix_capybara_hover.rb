When /^fix capybara focus$/ do

  # capybara does not retain focus on an element, that's why we override the jQuery focus function. See: https://github.com/mattheworiordan/jquery-focus-selenium-webkit-fix

  page.execute_script %Q(jQuery.find.selectors.filters.focus = function(elem) {
                           var doc = elem.ownerDocument;
                           return elem === doc.activeElement && !!(elem.type || elem.href);
                         })

end
