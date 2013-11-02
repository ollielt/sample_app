require 'spec_helper'

describe "Password Resets" do
  it "emails user when requesting password reset" do
    user = FactoryGirl.create(:user)
    visit signin_path
    click_link "password"
    fill_in "Email", with: user.email
    click_button "Reset Password"
    current_path.should eq(signin_path)
    page.should have_content('Email sent')
  end


  it "does not email invalid user when requesting password reset" do
    visit signin_path
    click_link "password"
    fill_in "Email", :with => "nobody@example.com"
    click_button "Reset Password"
    current_path.should eq(signin_path)
    page.should have_content('User with entered email address does not exist.')
    last_email.should be_nil
  end

# I added the following specs after recording the episode. It literally
# took about 10 minutes to add the tests and the implementation because
# it was easy to follow the testing pattern already established.
  it "updates the user password when confirmation matches" do
    user = FactoryGirl.create (:reset)
    visit edit_password_reset_path(user.password_reset_token)
    fill_in "Password", :with => "password"
    click_button "Update Password"
    page.should have_content("Password confirmation doesn't match Password")
    fill_in "Password", :with => "foobar"
    fill_in "Password confirmation", :with => "foobar"
    click_button "Update Password"
    page.should have_content("Password has been reset")
  end

  it "reports when password token has expired" do
    user = FactoryGirl.create(:reset_expire)
    visit edit_password_reset_path(user.password_reset_token)
    fill_in "Password", :with => "foobar"
    fill_in "Password confirmation", :with => "foobar"
    click_button "Update Password"
    page.should have_content("Password reset has expired")
  end

  it "raises record not found when password token is invalid" do
    lambda {
      visit edit_password_reset_path("invalid")
    }.should raise_exception(ActiveRecord::RecordNotFound)
  end
end

