require 'test_helper'

class DeliveryMailerTest < ActionMailer::TestCase
  test "password_delivery" do
    mail = DeliveryMailer.password_delivery
    assert_equal "Password delivery", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
