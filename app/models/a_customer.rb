class ACustomer < ActiveRecord::Base
  self.table_name = "customers"


  has_many :cars, class_name: "ACar"
end
