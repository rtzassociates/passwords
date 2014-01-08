require 'spec_helper'

describe 'site layout' do

  it "has a link to the home page" do
    visit root_path
    expect(page).to have_link "Password Mailer" 
  end

end
