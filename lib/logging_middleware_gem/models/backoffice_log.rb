require "mongoid"

module LoggingMiddlewareGem
  module Models
    class BackofficeLog
      include Mongoid::Document
      include Mongoid::Timestamps

      store_in collection: 'backoffice-log-collection'

      field :name, type: String
      field :request, type: Hash
      field :user, type: Hash
      field :payload, type: Hash
      field :response, type: Hash
    end
  end
end
