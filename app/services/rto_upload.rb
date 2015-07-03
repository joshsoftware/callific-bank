class RtoUpload
  include CommonMethods

  def initialize(file_path, user_email)
    @spreadsheet = open_file(file_path)
    @user_email = user_email
    @error_file_path = Rails.root + "public/uploads/rto_error_report_file.csv"
    @flag = false
  end

  def import_rto_data
    headers = get_headers(@spreadsheet)
    read_rto_data(headers)
  end

  def read_rto_data(headers)
    error_records = []
    begin
      (2..@spreadsheet.last_row).reduce(error_records) do |errors, index|
        record = Hash[
          [
            headers,
            @spreadsheet.row(index)[0..headers.length - 1]
          ].transpose
        ]

        hash_values_to_string(record)
        create_customer(record) ? errors : (errors << record.merge('errors' => @errors))
      end
    ensure
      create_error_file(error_records) if error_records.present?
    end
  end

  def create_customer(record)
    unless is_invalid_record(record)
      Customer.create(record: record)
    else
      false
    end
  end

  def is_invalid_record(record)
    #Convert MH12KY2080 to MH 12 KY 2080
    registration_no = record['registration_no']
                      .match(REGEXP_REG_NO).try(:captures).try(:join, ' ').to_s
    record['registration_no'] = registration_no

    valid_reg_no = registration_no.length.eql?(13)
    customer_present = Customer.where(
      'record.registration_no' => registration_no
    ).first

    @errors = (
      customer_present ? "<Customer already present> " : ''
      ) + (
        valid_reg_no ? '' : '<Invalid Format for Registration No>'
      )

    @errors.present?
  end

  def create_error_file(error_records)
    CSV.open(
      @error_file_path, 'w', write_headers: true,
      headers: error_records.first.keys.map(&:humanize)
    ) do |write|
      error_records.each{|record| write << record.values}
      @flag = true
    end
  end

end