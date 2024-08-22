
# LoggingMiddlewareGem

`LoggingMiddlewareGem` is a Rails middleware gem designed to log incoming requests, user details, and responses to a MongoDB database. It supports custom logging via a concern that allows you to easily add additional data to your logs.

## Installation

Add the gem to your Rails application's `Gemfile`:

```ruby
gem 'logging_middleware_gem'
```

Then, run:

```sh
bundle install
```

### MongoDB Setup

Ensure you have the following gems in your `Gemfile` to work with MongoDB:

```ruby
gem 'mongo', '~> 2'
gem 'mongoid', '~> 9.0'
```

Run `bundle install` after adding the above lines.

Next, generate the Mongoid configuration file if you haven't already:

```sh
rails g mongoid:config
```

Update your `mongoid.yml` configuration file with your MongoDB settings.

## Usage

### Middleware Configuration

To enable the logging middleware, add it to your Rails application. Edit `config/application.rb`:

```ruby
module YourApp
  class Application < Rails::Application
    # Other configurations...

    config.middleware.use LoggingMiddlewareGem::LoggingMiddleware
  end
end
```

### Logging Concern

To utilize the logging concern, include it in your controllers where you want to log additional data:

```ruby
class ApplicationController < ActionController::Base
  include LoggingMiddlewareGem::LoggingConcern

  # Other code...
end
```

### Adding Custom Log Data

Use the `add_to_log_data` method to add custom data to the log. Here’s an example:

```ruby
class OrdersController < ApplicationController
  def create
    @order = Order.new(order_params)
    
    if @order.save
      add_to_log_data(:order_id, @order.id)
      add_to_log_data(:order_total, @order.total)
      # Additional logic...
    else
      # Handle errors...
    end
  end

  private

  def order_params
    params.require(:order).permit(:product_id, :quantity, :price)
  end
end
```

In this example, the `order_id` and `order_total` are added to the log for each request that creates an order.

### Flipper Configuration

If you want to enable or disable the logging middleware dynamically, you can use [Flipper](https://github.com/jnunemaker/flipper). Add the following to enable logging:

```ruby
Flipper[:logging_middleware].enable
```

### Logged Data Structure

The logged data is stored in MongoDB in the `backoffice-log-collection`. The structure of the logged data includes:

- **Request Data:**
    - `http_verb`: The HTTP method used (e.g., GET, POST).
    - `route`: The full path of the request.
    - `user_agent`: The user agent string of the client making the request.
    - `ip`: The IP address of the client.
    - `params`: The request parameters, with sensitive data filtered out.
    - `headers`: The request headers, with sensitive data filtered out.

- **User Data:**
    - `email`: The email of the logged-in user.
    - `user_id`: The ID of the logged-in user.

- **Response Data:**
    - `status`: The HTTP status code returned by the server.
    - `headers`: The response headers.

Here’s an example of a log entry in MongoDB:

```json
{
  "_id": ObjectId("64e4cbe39b7c2e23b4fa1c2e"),
  "request": {
    "http_verb": "POST",
    "route": "/orders",
    "user_agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
    "ip": "192.168.1.10",
    "params": {
      "product_id": "12345",
      "quantity": "2",
      "price": "29.99"
    },
    "headers": {
      "host": "yourapp.com",
      "accept": "application/json"
    }
  },
  "user": {
    "email": "user@example.com",
    "user_id": "98765"
  },
  "response": {
    "status": 201,
    "headers": {
      "content-type": "application/json; charset=utf-8",
      "cache-control": "no-cache"
    }
  },
  "payload": {
    "order_id": "12345",
    "order_total": "59.98"
  },
  "created_at": ISODate("2024-08-22T12:34:56Z"),
  "updated_at": ISODate("2024-08-22T12:34:56Z")
}
```

### Error Handling

If an error occurs within the middleware, it will be logged to `Rails.logger`, and the request will proceed without logging to MongoDB.

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/lucasbilkmatos/logging_middleware_gem](https://github.com/lucasbilkmatos/logging_middleware_gem).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
```

You can copy and paste this directly into your `README.md` file.