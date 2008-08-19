class Admin::AdminController < ApplicationController
  require_role "admin"
  
end
