class PasswordListsController < ApplicationController
  def index
    @password_lists = PasswordList.all
  end
  
  def show
    @password_list = PasswordList.find(params[:id])
    @agencies = @password_list.agencies.search(params[:search]).page(params[:page]).per_page(50)
  end

  def new
    @password_list = PasswordList.new
  end
  
  def create
    @password_list = PasswordList.create(params[:password_list])
    @password_list.save
    redirect_to @password_list, :notice => "Password list succesfully created"
  end
  
  def destroy
    @password_list = PasswordList.find(params[:id])
    @password_list.destroy
    redirect_to password_lists_path, :notice => "Password list succesfully destroyed"
  end
  
  def edit
    @password_list = PasswordList.find(params[:id])
  end
  
  def update
    @password_list = PasswordList.find(params[:id])
    @password_list.update_attributes(params[:password_list])
    if @password_list.save
      redirect_to password_lists_path, :notice => "Password list updated successfully"
    else
      render 'edit'
    end
  end
end
