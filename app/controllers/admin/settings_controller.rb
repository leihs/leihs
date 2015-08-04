class Admin::SettingsController < Admin::ApplicationController

  before_filter do
    @setting = Setting.first || Setting.new
  end

  def edit
  end

  def update
    if @setting.update_attributes(params[:setting])
      flash[:notice] = _('Successfully set.')
      redirect_to admin_edit_settings_path
    else
      flash.now[:error] = @setting.errors.full_messages.uniq.join(', ')
      render :edit
    end
  end

end
