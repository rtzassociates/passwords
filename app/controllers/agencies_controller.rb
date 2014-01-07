class AgenciesController < ApplicationController
  
  def new
    @password_list = PasswordList.find(params[:password_list_id])
    @agency = Agency.new
  end
  
  def create
    @password_list = PasswordList.find(params[:password_list_id])
    @agency = Agency.new(params[:agency])
    @agency.password_list = @password_list
    if @agency.save
      redirect_to @agency.password_list, :notice => "Agency succesfully created"
    else
      render 'new'
    end
  end
  
  def edit
    @password_list = PasswordList.find(params[:password_list_id])
    @agency = Agency.find(params[:id])
  end
  
  def update
    @agency = Agency.find(params[:id])
    @agency.update_attributes(params[:agency])
    if @agency.save
      redirect_to @agency.password_list, :notice => "Agency succesfully updated"
    else
      render 'edit'
    end
  end
  
  def destroy
    @agency = Agency.find(params[:id])
    @agency.destroy
    redirect_to @agency.password_list, :notice => "Agency succesfully destroyed"
  end
  
end
