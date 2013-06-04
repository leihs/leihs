class Authenticator::AuthenticatorController < ApplicationController

  def login
    session[:locale] = nil
  end            
  
end