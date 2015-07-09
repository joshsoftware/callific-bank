class ACar < ActiveRecord::Base
  self.table_name = "customer_cars"

  belongs_to :customer, class_name: "ACustomer"
end
