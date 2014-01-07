class PasswordList < ActiveRecord::Base
  attr_accessible :month, :year
  
  has_many :agencies, :dependent => :destroy
  has_many :deliveries, :dependent => :destroy
  
  def name
    "#{month} #{year}".titleize
  end
  
  def has_been_delivered?
    scheduled_deliveries = deliveries.where("deliveries.delivered_at IS NOT NULL")
    if scheduled_deliveries.empty?
      false
    else
      true
    end
  end
end
