When 'I sort by "$sort_key"' do |sort_key|
  When "I click \"#{sort_key}\""
end

#no-sphinx#
When 'I count the number of indexed models' do
  # the following test will only work under Unix...
  @number = `grep -l define_index #{Rails.root}/app/models/* | wc -l`
end

Then 'that number must be the same as the number of search partials' do
  # see app/views/backend/backend/search/_nilclass.html.erb on why we exclude nilclass
  expect(@number).to eq `ls #{Rails.root}/app/views/backend/backend/search | grep -v nilclass | wc -l`
end
