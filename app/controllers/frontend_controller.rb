class FrontendController < ApplicationController

  require_role "customer"

  layout "frontend"
  
end
