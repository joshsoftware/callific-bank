class Customer
  include Mongoid::Document
  include Mongoid::Timestamps
  include Elasticsearch::Model

  after_save    { self.__elasticsearch__.index_document }
  after_destroy { self.__elasticsearch__.delete_document }

  index_name "callific_#{Rails.env}_verification_data"

  field :record, type: Hash

  index({'record.registration_no' => 1}, {unique: true, background: true})

  def as_indexed_json(options = {})
    record
  end

end
