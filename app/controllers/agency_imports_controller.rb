class AgencyImportsController < ApplicationController
  def new
    @password_list = PasswordList.find(params[:password_list_id])
  end

  def create
    @password_list = PasswordList.find(params[:password_list_id])
    if params[:agency_import]
      @agency_import = AgencyImport.new(@password_list, params[:agency_import])
    else
      flash[:error] = "Please choose a file to import"
      redirect_to @password_list
      return
    end
    
    if @agency_import.save
      redirect_to @password_list, notice: "Agencies succesfully imported"
    else
      render :new
    end
  end
end
