steps_for(:simple) do

  Given "None" do
    pending("missing")
  end
  
  When "Nothing happens" do
  end
  
  Then "flash appears" do
    get '/acknowledge/index'
    puts "*****"
    puts flash[:notice]
    puts "*****"
  end

end