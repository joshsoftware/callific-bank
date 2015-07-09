module CommonMethods

  def find_full_vendor_name(string)
    YAML.load_file("#{Rails.root}/config/vendor_list.yml")
    .select do |insurance_names|
      # for matching both
      # => Bhajaj alli , with only first word of 'insurance variable'
      insurance_names =~ /\b#{string.split[0]}\b/i || 
      # => BHARTIAXAGENINS, with first two words of 'el variable'
      string =~ /(?=.*#{insurance_names.split[0]}{1})(?=.*#{insurance_names.split[1]})/i
    end
    .first || 'Not found in Records'
  end

  def hash_values_to_string(hash)
    hash.each_key do |key|
      key_class = hash[key].class
      unless key_class.eql?(Array)
        hash[key] = key_class.eql?(String) ? 
                    hash[key].squish.upcase : hash[key].to_s.gsub(/\.0$/,'')
      else
        hash[key] = hash[key].map do |each_hash| 
          hash_values_to_string(each_hash)
        end
      end
    end
  end

  def get_file_type(file_path)
    /\.(?<extension>[a-z]+)/i =~ file_path
    extension
  end

  def get_file_name(file_path)
    /\/.*\/(?<file_name>.*)\./i =~ file_path
    file_name
  end

  def check_file_extension(file)
    extension = get_file_type(file.path)
    extension.in?(%w(csv xls xlsx)) ? true : false
  end
  
  def open_file(file_path)
    Roo::Spreadsheet.open(file_path, extension: get_file_type(file_path))
  end

  def set_current_company(company_subdomain)
    Company.current_id = Company.where(subdomain: company_subdomain).first.id
  end

  def get_headers(spreadsheet)
    spreadsheet.row(1).map(&:to_s).reduce([]){
      |arr, attribute| arr << attribute.try(:gsub, /\s+/, '_').try(:underscore)
    }
  end

end
