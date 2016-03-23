
placeholder :string_with_spaces do
  match /.*/ do |s|
    s
  end
end

placeholder :boolean do
  match /(is not|do not see|a non existing|have not)/ do
    false
  end

  match /(is|see|an existing|have)/ do
    true
  end
end
