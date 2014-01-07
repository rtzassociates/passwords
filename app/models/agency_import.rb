class AgencyImport
  # switch to ActiveModel::Model in Rails 4
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :file

  def initialize(password_list, attributes = {})
    @password_list = password_list
    attributes.each { |name, value| send("#{name}=", value) }
  end

  def persisted?
    false
  end

  def save
    begin
      if imported_agencies.map(&:valid?).all?
        imported_agencies.each(&:save!)
        true
      else
        imported_agencies.each_with_index do |agency, index|
          agency.errors.full_messages.each do |message|
            errors.add :base, "Row #{index+2}: #{message}"
          end
        end
        false
      end
    rescue => e
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
    (2..spreadsheet.last_row).map do |i|
      begin
        row = Hash[[header, spreadsheet.row(i)].transpose]
        agency = Agency.find_by_id(row["id"]) || Agency.new
        agency.attributes = row.to_hash.slice(*Agency.accessible_attributes)
        agency.password_list_id = @password_list.id
        agency
      end
    end
  end

  def open_spreadsheet
    case File.extname(file.original_filename)
    when ".csv" then Csv.new(file.path, nil, :ignore)
    when ".xls" then Excel.new(file.path, nil, :ignore)
    when ".xlsx" then Excelx.new(file.path, nil, :ignore)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end
end
