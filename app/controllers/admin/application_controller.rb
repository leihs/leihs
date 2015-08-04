class Admin::ApplicationController < ApplicationController

  layout 'admin'

  before_filter do
    not_authorized!(redirect_path: root_path) unless is_admin?
  end

end
