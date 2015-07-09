elasticsearch_client = YAML.load_file("#{Rails.root}/config/elasticsearch.yml")[Rails.env]

ES_CLIENT = Elasticsearch::Client.new url: elasticsearch_client['url']#, log: true

Elasticsearch::Model.client = ES_CLIENT
Elasticsearch::Persistence.client = ES_CLIENT