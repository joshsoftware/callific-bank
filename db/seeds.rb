=begin
  #Create Insurance Vendor
    vendors = YAML.load_file("#{Rails.root}/config/vendor_list.yml")

    vendors.each do |iv|
      InsuranceVendor.find_or_create_by(vendor_name: iv)
    end

  #Create RTO
    rto_names = [
      "NAGPUR", "PCMC", "PUNE", "HYDERABAD", "WARDHA", "ANDHERI", "TARDEO",
      "WORLI", "THANE", "AURANGABAD", "RAIGAD", "VASHI", "AHMEDNAGAR", "DELHI",
      "SHRIRAMPUR", "SATARA", "NASHIK", "AKLUJ", "LATUR", "BARAMATI", "PARBHANI",
      "CHANDIGARH", "RATNAGIRI", "KOLHAPUR", "SOLAPUR", "JALGAON", "SANGLI",
      "BHOPAL", "AKOLA", "GONDIYA", "DHULE", "KALYAN", "MALEGAON", "KARAD",
      "HINGOLI", "BEED"]

    rto_names.each do |name|
      Rto.find_or_create_by( 
        city: name, name: name, state: "TEST STATE"
      )
    end
=end

#create Users
  #ADMIN
  User.find_or_create_by!(
    email: "admin@callific.in",
    password: 'josh1234', 
    password_confirmation: 'josh1234'
  )