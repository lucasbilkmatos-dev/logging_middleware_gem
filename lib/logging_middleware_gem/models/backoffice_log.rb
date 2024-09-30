require "mongoid"

module LoggingMiddlewareGem
  module Models
    class BackofficeLog
      include Mongoid::Document
      include Mongoid::Timestamps

      MONGO_DB_LOG_COLLECTION = ENV.fetch("MONGO_DB_LOG_COLLECTION", "backoffice-log-collection")

      store_in collection: MONGO_DB_LOG_COLLECTION

      field :name, type: String
      field :http, type: Hash
      field :user, type: Hash
      field :payload, type: Hash
    end
  end
end
