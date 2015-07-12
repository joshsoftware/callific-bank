require "#{Rails.root}/lib/common_methods.rb"
include CommonMethods

namespace :migrate do
 task data: :environment do
   ACustomer.includes(:cars).find_each(batch_size: 1000).with_index do |customer, i|
    customer.cars.each do |car|
      
      customer_data = {
        customer_name: customer.name
      }.merge(
        customer.as_json(
          only: [
            :phone, :mobile, :other_phone, :email, :address,
            :whom_to_contact, :other_email
          ]
        )
      )

      car_detail = car.car
      
      customer_data.merge!(
        car.as_json(
          only:[
            :registration_no, :registration_date, :engine_no, :chasis_no,
            :color
          ]
        ).merge(
          {
            manufacture_year: car.manufacturing_year,
            manufacture_month: car.manufacturing_month,
            car_make: car_detail.make,
            car_model: car_detail.model,
            cubic_capacity: car_detail.cubic_capacity,
            seating_capacity: car_detail.seating_capacity
          }
        )
      )

      customer_data['registration_no'] = customer_data['registration_no']
        .match(REGEXP_REG_NO).try(:captures)
        .try(:join, ' ').to_s || "-NA-#{Time.now.to_i}"

      hash_values_to_string(customer_data)

      Customer.create!(record: customer_data) rescue false
    end
    print "#{i}" if i%1000 == 0
   end
 end
end
