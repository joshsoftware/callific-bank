class Customer
  include Mongoid::Document
  include Mongoid::Timestamps
  include Elasticsearch::Model

  after_save    { self.__elasticsearch__.index_document }
  after_destroy { self.__elasticsearch__.delete_document }

  index_name "callific_bank_#{Rails.env}_data"

  field :record, type: Hash
  field :name
  field :birth_date, type: Date
  field :phone
  field :mobile
  field :other_phone
  field :email
  field :other_email
  field :address
  field :whom_to_contact

  has_many :customer_cars

  index({'record.registration_no' => 1}, {unique: true, background: true})

  def as_indexed_json(options = {})
    record
  end

end
