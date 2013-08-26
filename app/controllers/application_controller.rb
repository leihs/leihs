class ApplicationController < ActionController::Base

  require File.join(Rails.root, 'lib', 'authenticated_system.rb')
  include AuthenticatedSystem

  before_filter :set_gettext_locale, :load_settings

  layout "splash"

  protect_from_forgery

  def index
    if logged_in?
      if current_user.has_role?('manager', nil, false) or current_user.has_role?('admin')
        redirect_to backend_path, flash: flash
      else
        redirect_to borrow_root_path, flash: flash
      end
    else
      render "splash/show"
    end
  end
 
  protected

  helper_method :current_inventory_pool
  
  # TODO **20 optimize lib/role_requirement and refactor to backend  
  def current_inventory_pool
    nil
  end

  def add_visitor(user)
    session[:last_visitors] ||= []
    session[:last_visitors].delete([user.id, user.name])
    session[:last_visitors].delete_at(0) if session[:last_visitors].size > 4 
    session[:last_visitors] << [user.id, user.name]
  end

  def set_gettext_locale
    language = if params[:locale]
      Language.where(:locale_name => params[:locale]).first
    elsif current_user
      current_user.language
    elsif session[:locale]
      Language.where(:locale_name => session[:locale]).first
    end
    language ||= Language.default_language
    current_user.update_attributes(:language_id => language.id) if current_user and (params[:locale] or current_user.language_id.nil?)
    session[:locale] = language.locale_name
    I18n.locale = language.locale_name.to_sym
  end

  def load_settings
    if not Setting.const_defined?("SMTP_ADDRESS") and logged_in? and not [backend_settings_path, logout_path].include? request.path
      if current_user.has_role?('admin')
        redirect_to backend_settings_path
      else
        raise "Application settings are missing!"
      end
    end
  end

end
