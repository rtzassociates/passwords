class DeliveryMailer < ActionMailer::Base
  def password_delivery(password_list, agency)
    @agency = agency
    @password_list = password_list
    subject = "RTZ Associates, Inc: #{password_list.name} Password"  
    mail to: @agency.recipients, :subject => subject, from: "RTZ Associates<help@getcare.com>"
  end
end
