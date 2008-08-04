class MailerController < ApplicationController
  layout "mailer"

  init_gettext "rails_test"
  
  def index
    render :nothing => true, :layout => true
  end

  def singlepart
    Mailer.deliver_singlepart
    render :text => Mailer.create_singlepart.encoded, :layout => true
  end

  def multipart
    Mailer.deliver_multipart
    render :text => Mailer.create_multipart.encoded, :layout => true
  end
end
