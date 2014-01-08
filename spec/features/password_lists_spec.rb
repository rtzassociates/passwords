require 'spec_helper'

describe "password_lists index" do

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

    end

  end

end
