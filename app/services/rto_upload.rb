class RtoUpload
  include CommonMethods

  def initialize(file_path)
    @spreadsheet = open_file(file_path)
  end

  def import_rto_data(rto_file)
    headers = get_headers(@spreadsheet)
    read_rto_data(headers, rto_file)
  end

  def read_rto_data(headers, rto_file)
    (2..@spreadsheet.last_row).each do |index|
      record = Hash[
        [
          headers,
          @spreadsheet.row(index)[0..headers.length - 1]
        ].transpose
      ]

      hash_values_to_string(record)
      create_customer(record)
    end
  end

  def create_customer(record)
    customer = Customer.find_or_initialize_by(record: record)
    validate_customer_and_create_car_info(customer, record)
  end

  def validate_customer_and_create_car_info(customer, record)
    if record['registration_no'] =~ /[A-Za-z]{2}\s*[0-9]{2}\s*[A-Za-z]{2}\s*[0-9]{4}/
      customer.save!
    end
  end
end