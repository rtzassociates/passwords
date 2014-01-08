require 'spec_helper'

describe AgencyImport do

  let(:file) do
    extend ActionDispatch::TestProcess
    fixture_file_upload('/valid_spreadsheet.xls', 'application/octet-stream')
  end

end
