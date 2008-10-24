class UsersController < ApplicationController
  def custom_error_message
    @user = User.new
    @user.name = "foo"
    unless params[:plural]
      @user.lastupdate = "2007-01-01"
    end
    @user.valid?
    @user.lastupdate = "2007-01-01"
  end
end
