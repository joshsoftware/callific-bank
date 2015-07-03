class RtoUpload
  include CommonMethods

  def initialize(file_path, user_email)
    @spreadsheet = open_file(file_path)
    @user_email = user_email
    @new_customers = []
  end

  def import_rto_data
    headers = get_headers(@spreadsheet)
    read_rto_data(headers)
    Customer.collection.insert(@new_customers) if @new_customers.any?
  end

  def read_rto_data(headers)
    (2..@spreadsheet.last_row).each do |index|
      record = Hash[
        [
          headers,
          @spreadsheet.row(index)[0..headers.length - 1]
        ].transpose
      ]

      hash_values_to_string(record)
      collect_customer(record)
    end
  end

  def collect_customer(record)
    
    #Convert MH12KY2080 to MH 12 KY 2080
    registration_no = record['registration_no'].match(REGEXP_REG_NO).captures.join(' ')
    record['registration_no'] = registration_no
    
    if registration_no.length == 13
      customer = Customer.where(
          'record.registration_no' => registration_no
        ).first || Customer.new
      
      customer.attributes = {record: record}
      customer.new_record? ? @new_customers << customer.as_json : customer.save!
    end
  end
end