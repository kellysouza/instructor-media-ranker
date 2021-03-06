class SessionsController < ApplicationController
  skip_before_action :require_login, only: [:create, :login]


  def login_form
  end

  def login
    username = params[:username]
    if username and user = User.find_by(username: username)
      session[:user_id] = user.id
      flash[:status] = :success
      flash[:result_text] = "Successfully logged in as existing user #{user.username}"
    else
      user = User.new(username: username)
      if user.save
        session[:user_id] = user.id
        flash[:status] = :success
        flash[:result_text] = "Successfully created new user #{user.username} with ID #{user.id}"
      else
        flash.now[:status] = :failure
        flash.now[:result_text] = "Could not log in"
        flash.now[:messages] = user.errors.messages
        render "login_form", status: :bad_request
        return
      end
    end
    redirect_to root_path
  end


  def create
    #request os a rails thing
    #omniauth.auth is a onmiauth thing
    auth_hash = request.env['omniauth.auth']
    # raise
    user = User.find_by(uid: auth_hash["uid"], provider: auth_hash["provider"])
    #if it is not there them make/save it
    if user.nil?
      user = User.create_from_github(auth_hash)
      if user.nil?
        flash[:error] = "Could not log in."
        redirect_to root_path
      end
    end
      #if it is there then save some data to session the redirect
      session[:user_id] = user.id
      flash[:success] = "Logged in succesfully!"
      redirect_to root_path
  end


  def logout
    session[:user_id] = nil
    flash[:status] = :success
    flash[:result_text] = "Successfully logged out"
    redirect_to root_path
  end
end
