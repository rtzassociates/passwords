class Delivery < ActiveRecord::Base
  attr_accessible :deliver_at, :delivered_at, :job_id
  
  belongs_to :password_list
  validates :deliver_at, :presence => { :message => " is not valid" }
  
  attr_writer :deliver_at_text
  before_save :save_deliver_at_text 
  validate :check_deliver_at_text
  
  before_destroy :destroy_delayed_jobs

  def deliver!
    password_list.agencies.each do |agency|
      DeliveryMailer.password_delivery(password_list, agency).deliver
    end
    self.delivered_at = Time.zone.now
    self.save!
  end
  
  def deliver_at_text
    @deliver_at_text || deliver_at.try(:strftime, "%Y-%m-%d %H:%M:%S")
  end
  
  def save_deliver_at_text
    self.deliver_at = Time.zone.parse(@deliver_at_text) if @deliver_at_text.present?
  end
  
  def check_deliver_at_text
    if @deliver_at_text.present? && Time.zone.parse(@deliver_at_text).nil?
      errors.add :deliver_at_text, "cannot be parsed"
    end
  rescue ArgumentError
    errors.add :deliver_at_text, "is out of range"   
  end
  
  def delayed_job
    begin
      Delayed::Job.find(self.job_id)
    rescue
      nil
    end
  end
  
  private
  
  def destroy_delayed_jobs
    delayed_job.destroy if delayed_job
  end
  
end
