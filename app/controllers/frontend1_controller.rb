# TODO remove this controller when there are no subcontrollers

class Frontend1Controller < ApplicationController

  #old# prepend_before_filter :login_required
  require_role "student"
  
end
