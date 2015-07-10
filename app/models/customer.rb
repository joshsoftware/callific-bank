class Customer
  include Mongoid::Document
  include Mongoid::Timestamps
  include Elasticsearch::Model

  after_save    { self.__elasticsearch__.index_document }
  after_destroy { self.__elasticsearch__.delete_document }

  index_name "callific_bank_#{Rails.env}_data"

  field :record, type: Hash

  index({'record.registration_no' => 1}, {unique: true, background: true})

  def as_indexed_json(options = {})
    record.as_json(except: 'birth_date')
  end

  def self.search(query)
    @@customer_count ||= self.count
    __elasticsearch__.search(
      {
        size: @@customer_count,
        query: {
          simple_query_string: {
            query: query,
            default_operator: 'and'
          }
        }
      }
    )
  end

end
