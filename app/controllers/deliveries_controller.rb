class DeliveriesController < ApplicationController
   
  def index
    @password_list = PasswordList.find(params[:password_list_id])
  end
  
  def show
  end

  def new
    @password_list = PasswordList.find(params[:password_list_id])
    @delivery = Delivery.new
  end
  
  def create
    @password_list = PasswordList.find(params[:password_list_id])
    @delivery = Delivery.new(params[:delivery])
    @delivery.password_list = @password_list
    if @delivery.save
      job = @delivery.delay(run_at: @delivery.deliver_at).deliver!
      @delivery.job_id = job.id
      @delivery.save!
      redirect_to @password_list, :notice => "Delivery succesfully scheduled"
    else
      render 'new'
    end
  end
  
  def destroy
    @password_list = PasswordList.find(params[:password_list_id])
    @delivery = Delivery.find(params[:id])
    if @delivery.delayed_job
      @delivery.delayed_job.destroy
      @delivery.destroy
      flash[:notice] = "Delivery successfully canceled"
    else
      flash[:error] = "Delivery has already been sent"
    end
    redirect_to @password_list
  end
  
end
