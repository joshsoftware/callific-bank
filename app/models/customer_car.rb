class CustomerCar
  include Mongoid::Document

  field :registration_no
  field :registration_date,   type: Date
  field :manufacturing_month, type: Integer
  field :manufacturing_year,  type: Integer
  field :engine_no
  field :chasis_no
  field :color

  belongs_to :customer
end
