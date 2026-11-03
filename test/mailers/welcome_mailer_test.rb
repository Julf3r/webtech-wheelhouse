require "test_helper"

class WelcomeMailerTest < ActionMailer::TestCase
  test "welcome" do
    user = users(:one)
    mail = WelcomeMailer.welcome(user)

    assert_equal "Welcome to Wheelhouse!", mail.subject
    assert_equal [user.email_address], mail.to
    assert_match "Welcome to Wheelhouse!", mail.body.encoded
  end
end