class DealerUpload
  include CommonMethods

  def initialize(file_path, user_email)
    @spreadsheet = open_file(file_path)
    @file_path = "#{Rails.root}/public/uploads/Latest Corrected RTO Sheet.xlsx"
    @user_email = user_email
  end

  def import_dealer_data
    headers = get_headers(@spreadsheet)
    read_rto_data(headers)
    UserMailer.send_dealer_data_upload_status(@file_path, @user_email).deliver_now
  end

  def read_rto_data(headers)
    matched_records = []

    (2..@spreadsheet.last_row).each do |index|
      record = Hash[
        [
          headers,
          @spreadsheet.row(index)[0..headers.length - 1]
        ].transpose
      ]

      hash_values_to_string(record)
      
      matched_records << find_match_and_return_merged_data(record)
    end

    store_corrected_data(matched_records)
  end

  def store_corrected_data(matched_records)
    p = Axlsx::Package.new
    p.workbook.add_worksheet(:name => "Matched Dealer Data") do |sheet|
      insert_matched_records(matched_records, sheet)
    end
    p.serialize(@file_path)
  end

  def insert_matched_records(matched_records, sheet)
    sheet.add_row @new_header
    matched_records.each do |record|
      sheet.add_row record.values if record
    end
  end

  def find_match_and_return_merged_data(record)
    match_found = nil

    ['must', 'should'].each do |condition|
      matches = Customer.__elasticsearch__.search(
        {
          query: {
            bool: {
              condition => [
                {
                  bool: {
                    must: partial_matching_fields(
                      record,
                      [
                        ['customer_name', '0.7'],
                        ['car_model', '0.7'],
                        ['address', '0.5']
                      ]
                    ),
                    boost: 1
                  }
                },
                {
                  query_string: {
                    query: regex_query_for(record, ['chasis_no', 'engine_no']),
                    boost: 100
                  }
                }
              ]
            }
          }
        }
      )

      matches_count = matches.count
      
      if matches_count == 1 || matches_count > 1
        match_found = matches.first and break
      end
    end

    merge_matched_and_rto_data(match_found, record)
  end

  def regex_query_for(record, fields)
    fields.each_with_index.reduce('') do |query, (field, index)|
      query += "#{field}:*#{record[field].split.first}#{' AND ' unless index.eql?(fields.length - 1)}"
    end
  end

  def partial_matching_fields(record, fields_with_percent)
    fields_with_percent.reduce([]) do |arr, arr_field_with_percent|
      field, percent = arr_field_with_percent
      arr << {
        more_like_this_field: {
          field => {
            like_text: record[field],
            min_term_freq: 1,
            percent_terms_to_match: percent
          }
        }
      }
    end
  end

  def merge_matched_and_rto_data(match_found, record)
    merged_data = match_found && record.merge(
      match_found._source.as_json(
        except: [
        'customer_name', 'address', 'primary_phone', 'other_phone', 'mobile'
        ]
      )
    )

    update_customer_record(merged_data) if merged_data

    @new_header ||= merged_data.keys.map(&:humanize)
    merged_data
  end

  def update_customer_record(merged_data)
    customer = Customer.where(
      'record.registration_no' => merged_data['registration_no']
      ).first

    customer && customer.update(record: merged_data)
  end

end