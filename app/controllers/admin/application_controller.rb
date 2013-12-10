class Admin::ApplicationController < ApplicationController

  layout 'manage'

  before_filter do
    not_authorized!(root_path) unless is_admin?
  end

end
