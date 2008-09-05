class FrontendController < ApplicationController

  require_role "student"

  layout 'frontend'
    
end
