module MainHelpers
  extend ActiveSupport::Concern

  included do
    require File.join(Rails.root, 'lib', 'authenticated_system.rb')
    include AuthenticatedSystem

    before_filter :set_gettext_locale, :load_settings, :permit_params

    protect_from_forgery

    protected

    helper_method :current_inventory_pool, :current_managed_inventory_pools, :is_admin?

    # TODO **20 optimize lib/role_requirement and refactor to backend
    def current_inventory_pool
      nil
    end

    def current_managed_inventory_pools
      current_user.inventory_pools.managed.sort
    end

    def add_visitor(user)
      session[:last_visitors] ||= []
      session[:last_visitors].delete([user.id, user.name])
      session[:last_visitors].delete_at(0) if session[:last_visitors].size > 4
      session[:last_visitors] << [user.id, user.name]
    end

    def set_gettext_locale
      language =
          if params[:locale]
            Language.where(locale_name: params[:locale]).first
          elsif current_user
            current_user.language
          elsif session[:locale]
            Language.where(locale_name: session[:locale]).first
          end
      language ||= Language.default_language
      unless language.nil?
        current_user.update_attributes(language_id: language.id) if current_user and (params[:locale] or current_user.language_id.nil?)
        session[:locale] = language.locale_name
        I18n.locale = language.locale_name.to_sym
      end
    end

    def load_settings
      if not Setting.smtp_address and logged_in? and not [admin.settings_path, main_app.logout_path].include? request.path
        if current_user.has_role?(:admin)
          redirect_to admin.settings_path
        else
          raise 'Application settings are missing!'
        end
      end
    end

    def set_pagination_header(paginated_active_record)
      headers['X-Pagination'] = {
          total_count: paginated_active_record.total_entries,
          per_page: paginated_active_record.per_page,
          offset: paginated_active_record.offset
      }.to_json
    end

    ##################################################
    # ACL

    def not_authorized!(options = {redirect_path: nil})
      options[:redirect_path] ||= admin.inventory_pools_path
      msg = "You don't have appropriate permission to perform this operation."

      respond_to do |format|
        format.html do
          flash[:error] = msg
          redirect_to options[:redirect_path]
        end
        format.json { render text: msg }
      end
    end

    ####### Helper Methods #######

    def is_admin?
      current_user.has_role?(:admin)
    end

    def permit_params
      params.permit!
    end

  end


end