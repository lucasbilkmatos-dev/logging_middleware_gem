require "mongoid"

module LoggingMiddlewareGem
  module Models
    class BackofficeLog
      include Mongoid::Document
      include Mongoid::Timestamps

      store_in collection: 'backoffice-log-collection'

      field :name, type: String
      field :http, type: Hash
      field :user, type: Hash
      field :payload, type: Hash
    end
  end
end
