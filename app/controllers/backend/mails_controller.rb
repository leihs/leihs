class Backend::MailsController < Backend::BackendController

  before_filter :pre_load
  before_filter :authorized?

  def new
    if @user.email.blank?
      flash[:error] = _('The user does not have an email address')
      # TODO
      redirect
    else
      # instead of sanitizing the user's name (see to_full_email_address
      # below, we use her email address only
      @to   = @user.email
      @from = if current_inventory_pool
                to_full_email_address( current_inventory_pool.name,
                                       (current_inventory_pool.email.blank? ?
                                          DEFAULT_EMAIL :
                                          current_inventory_pool.email))
              else
                DEFAULT_EMAIL
              end
      @source_path = params[:source_path]                               
    end
  end
  
  def create
    Notification.user_email params[:from], params[:to], params[:subject], params[:body]
    flash[:notice] = _('The mail was sent')
    redirect_to params[:source_path]
  end
  
private

  # ATTENTION - we do NOT sanitize the name here, which could contain
  # ", \, \0, \n etc.
  # Additionally, it's up to ActionMailer to encode the resulting string
  # correctly, which according to my tests it does
 def to_full_email_address(name, email)
    '"%s" <%s>' % [name, email]
  end
 
  def pre_load
    @user = User.find params[:user_id]
  end

  def authorized?
    not_authorized! unless is_admin? or is_privileged_user?
  end
end
