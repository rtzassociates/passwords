require 'spec_helper'

describe "password lists" do

  context "when there are no password lists" do

    it "says nothing to show" do
      visit password_lists_path
      expect(page).to have_content "There are no password lists to show."
    end

  end

end

describe "creating a password list" do

  let(:month) { 1.month.from_now.strftime("%B") }
  let(:year)  { 1.month.from_now.strftime("%Y") }

  it "creates a password list" do
    visit password_lists_path
    click_link "New Password List"
    expect(page).to have_content "Which month is this password list for?"
    select month, from: "Month"
    select year, from: "Year"
    click_button "Create List"
    expect(page).to have_content "Password list succesfully created"
    expect(page).to have_content "#{month} #{year}"
  end

  it "has next month and year as the selected defaults" do
    visit new_password_list_path
    expect(page).to have_select('password_list_month', selected: month)
    expect(page).to have_select('password_list_year', selected: year)
  end

  it "doesn't show the previous years" do
    previous_year = 1.year.ago.strftime("%Y")
    visit new_password_list_path
    expect(page).to_not have_content previous_year
  end

end

describe "adding an agency to a password list" do

  let(:password_list) { create(:password_list) }

  context "with no agencies" do

    describe "manually adding an agency" do
      
      it "successfully adds an agency" do 
        visit password_list_path(password_list)
        click_link "Add an agency"
        fill_in "Agency Name", with: "Test Agency"
        fill_in "Recipients", with: "agency@example.com"
        fill_in "Password", with: "secret"
        click_button "Create Agency"
        expect(page).to have_content "Agency succesfully created"
        expect(page).to have_content "Test Agency"
      end

      it "doesn't add an invalid agency" do
        visit password_list_path(password_list)
        click_link "Add an agency"
        click_button "Create Agency"
        expect(page).to have_content "Please correct the following errors"
      end

    end

    describe "importing a spreadsheet" do

      it "creates agencies from a valid spreadsheet" do
        visit password_list_path(password_list)
        expect(page).to have_content "Password Spreadsheet Import"
        expect(page).to have_content 'Choose an Excel spreadsheet below. Then click "Import File."'
        attach_file "agency_import_file", "/Users/james/code/passwords/spec/fixtures/valid_spreadsheet.xls"
        click_button "Import File"
        expect(page).to have_content "Agencies succesfully imported"
        %w{test_agency agency@example.com test_password}.each do |item|
          expect(page).to have_content item
        end
      end

      it "returns a validation error when a field is missing" do
        visit password_list_path(password_list)
        attach_file "agency_import_file", "/Users/james/code/passwords/spec/fixtures/invalid_spreadsheet.xls"
        click_button "Import File"
        expect(page).to have_content "Row 2: Name can't be blank"
      end

    end

    describe "scheduling a delivery" do
      
      it "successfully schedules a delivery" do
        password_list = create(:password_list)
        agency = create(:agency, password_list: password_list)
        current_time = Time.now.strftime("%b %e, %Y at %l:%M %p")  #Jan 8, 2014 at 12:00 AM

        visit password_list_path(password_list)
        expect(page).to have_content "There are no deliveries scheduled for this password list."
        click_link "Schedule a delivery"
        fill_in "When would you like these delivered?", with: current_time
        click_button "Schedule it!"
        expect(page).to have_content "Delivery succesfully scheduled"
        expect(page).to have_content current_time 
      end

      it "doesn't schedule a delivery with an invalid time" do
        password_list = create(:password_list)
        agency = create(:agency, password_list: password_list)
        current_time = "INVALID TIME"
        visit password_list_path(password_list)
        click_link "Schedule a delivery"
        fill_in "When would you like these delivered?", with: current_time
        click_button "Schedule it!"
        expect(page).to have_content "Delivery time is not valid"
      end

      it "clicking nevermind should always return you to the password list" do
        password_list = create(:password_list)
        agency = create(:agency, password_list: password_list)
        current_time = "INVALID TIME"
        visit password_list_path(password_list)
        click_link "Schedule a delivery"
        click_button "Schedule it!"
        expect(page).to have_content "Delivery time is not valid"
        click_link "Nevermind"
        expect(page).to have_content "Agency List"
      end

    end
    
    describe "delivering the message" do
      
      it "successfully delivers the message" do
        Delayed::Worker.delay_jobs = false

        password_list = create(:password_list)
        agency = create(:agency, password_list: password_list)
        current_time = Time.now.strftime("%b %e, %Y at %l:%M %p")  #Jan 8, 2014 at 12:00 AM

        visit password_list_path(password_list)
        expect(page).to have_content "There are no deliveries scheduled for this password list."
        click_link "Schedule a delivery"
        fill_in "When would you like these delivered?", with: current_time
        click_button "Schedule it!"

        expected_message = <<-eos
#{agency.name},\r
\r
Please see your #{password_list.name} password: #{agency.password}\r
        eos

        expect(last_email.to).to include(agency.recipients)
        expect(last_email.body.encoded).to match(expected_message)
      end

    end

    describe "searching for an agency" do
      it "finds the correct agency" do
        password_list = create(:password_list)
        agency1 = create(:agency, name: "Test Agency 1", password_list: password_list)
        agency2 = create(:agency, name: "Test Agency 2", password_list: password_list)
        visit password_list_path(password_list)
        fill_in "Agency Name", with: "Test Agency 1"
        click_button "Search"
        expect(page).to have_content "Test Agency 1"
        expect(page).to_not have_content "Test Agency 2"
      end
    end

  end

end
