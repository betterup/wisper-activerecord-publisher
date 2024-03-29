# Wisper::Activerecord::Publisher
> Extract logic from your callbacks into wisper listeners for model events
(create, update, delete)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'wisper-activerecord-publisher'
```

And then execute:

    $ bundle

## Usage

Create a wisper listener with methods named to match any of the supported
broadcast events:
* MODEL_created - event is published after record created in DB
* MODEL_updated - event is published after record is updated and includes attributes that changed
* MODEL_destroyed - event is published after record is destroyed and includes a read-only copy of the model attributes

This gem *does* support background event processing since the events are
published after commit and each event includes the necessary payload (ie:
changes).

### Example

```ruby
class Foo < ActiveRecord::Base
end

class MyListener
  def foo_created(model)
    # do something here with the model
  end

  def foo_updated(model, changes)
  end

  def foo_destroyed(model_attributes)
    # read-only copy of attributes
    # model is already deleted from database
  end
end
```

### Limiting events per model

Rather than have a model broadcast all events, you can limit them using the `broadcast_on` method.

```ruby
class Foo < ActiveRecord::Base
  broadcast_on :create
end

class MyListener
  def foo_created(model)
    # do something here with the model
  end

  def foo_updated(model, changes)
    # Will not be called
  end

  def foo_destroyed(model_attributes)
    # Will not be called
  end
end
```

### Changing default event broadcasts

You can turn off or limit broadcasts for all models in your application via an initializer.

```ruby
# config/initializers/wisper_activerecord_publisher.rb

Wisper::ActiveRecord::Publisher.configure do |config|
  config.default_broadcast_events = [:create, :update] # Only broadcast create and update events
end
```

Additionally, you can disable all broadcasts in a model by calling `disable_all_lifecycle_broadcasts!` on the model
class.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/betterup/wisper-activerecord-publisher.

