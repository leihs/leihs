# TODO remove this controller

class Backend::TemporaryController < ApplicationController
  
  def login
    if request.post?
      if params[:user_name].include?('hacker')
        
      else
        id = "1-" + params[:user_name] if params[:user_name].include?('admin')
        id ||= "2-" + params[:user_name]
        redirect_to "http://localhost:3000/authenticator/zhdk/login_successful/" + id
      end
    end
  end
  
  def user_info(id = params[:id])

    @id = id[0..id.index('-') - 1]
    @name = id[id.index("-") + 1..id.length]
    @user = User.find_by_login(@name)
    @user ||= User.new(:login => @name, :unique_id => rand(50000))
    @groups = []
    if @id.eql?("1") 
      @groups << 'admin'
    end
    render :action => 'user_info', :layout => false
  end
  
end
