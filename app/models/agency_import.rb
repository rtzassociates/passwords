class AgencyImport

  # included to support validations
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :file

  # takes a password list and sets attributes on the model
  def initialize(password_list, attributes = {})
    @password_list = password_list
    attributes.each { |name, value| send("#{name}=", value) }
  end

  def persisted?
    false
  end

  def save
    begin
      # only save the records if all agencies are valid
      if imported_agencies.map(&:valid?).all?
        imported_agencies.each(&:save!)
        true
      else
        # otherwise identify the row in the spreadsheet that fails validation
        imported_agencies.each_with_index do |agency, index|
          agency.errors.full_messages.each do |message|
            errors.add :base, "Row #{index+2}: #{message}"
          end
        end
        false
      end
    rescue => e
      # if the file can't be processed at all
      errors.add :base, "Import failed. Please check your password spreadsheet for formating errors."
      false
    end
  end

  def imported_agencies
    @imported_agencies ||= load_imported_agencies
  end

  def load_imported_agencies
    spreadsheet = open_spreadsheet
    header = ["name", "recipients", "password"]
    (2..spreadsheet.last_row).map do |i| # ignore the first line in the spreadsheet
      begin
        # Turns header and row into a hash of key => value pairs
        # ex:
        # [["name", "recipients", "password"], ["test", "agency@example.com", "secret"]] =>
        # [["name", "test"], ["recipients", "agency@example.com"], ["password", "secret"]]
        row = Hash[[header, spreadsheet.row(i)].transpose]
        agency = Agency.find_by_id(row["id"]) || Agency.new
        # only assign whitelisted attributes ( ignore ids for example )
        agency.attributes = row.slice(*Agency.accessible_attributes)
        agency.password_list_id = @password_list.id
        agency
      end
    end
  end

  def open_spreadsheet
    case File.extname(file.original_filename)
    when ".xls" then Excel.new(file.path, nil, :ignore)
    when ".xlsx" then Excelx.new(file.path, nil, :ignore)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end
end
