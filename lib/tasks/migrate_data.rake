require "#{Rails.root}/lib/common_methods.rb"
include CommonMethods

namespace :migrate do
 task data: :environment do
   ACustomer.includes(:cars).find_each(batch_size: 1000) do |customer|
    customer.cars.each do |car|
      
      customer_data = {
        customer_name: customer.name
      }.merge(
        customer.as_json(
          only: [
            :birth_date, :phone, :mobile, :other_phone, :email, :address,
            :whom_to_contact, :other_email
          ]
        )
      )
      
      customer_data.merge!(
        car.as_json(
          only:[
            :registration_no, :registration_date, :engine_no, :chasis_no,
            :color
          ]
        ).merge(
          {
            manufacture_year: car.manufacturing_year,
            manufacture_month: car.manufacturing_month
          }
        )
      )

      customer_data['registration_no'] = customer_data['registration_no']
        .match(REGEXP_REG_NO).try(:captures)
        .try(:join, ' ').to_s || "-NA-#{Time.now.to_i}"

      hash_values_to_string(customer_data)

      Customer.create!(record: customer_data) rescue false
    end
   end
 end
end
