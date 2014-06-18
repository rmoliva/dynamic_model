dynamic_model
=============

[![Build Status](https://secure.travis-ci.org/rmoliva/dynamic_model.png)](http://travis-ci.org/rmoliva/dynamic_model)
[![Code Climate](https://codeclimate.com/github/rmoliva/dynamic_model.png)](https://codeclimate.com/github/rmoliva/dynamic_model)
[![Code Climate](https://codeclimate.com/github/rmoliva/dynamic_model/coverage.png)](https://codeclimate.com/github/rmoliva/dynamic_model)

dynamic_model is a gem that let you define the attributes of a model dynamically on the database.

The idea behind this is not to hard code the attributes of a model inside its code but in the database.
Obviously those attributes have limited functionality, but this approach helps change the definition of the application models without throwing a single line of code or restarting the server: simply adding or removing database rows.

It's currently under development... 

## Installation

### Rails 3 & 4

1. Add DynamicModel to your `Gemfile`.

    `gem 'dynamic_model'

2. Generate a migration which will add a `attributes` and `values` tables to your database.

    `bundle exec rails generate dynamic_model:install`

3. Run the migration.

    `bundle exec rake db:migrate`

4. Add `has_dynamic_model` to the models you want to dynamic.

## Documentation

Suppose you have the following model:

```ruby
class Person < ActiveRecord::Base
  has_dynamic_model
end
```

You can programmatically add columns to the model with the method:  

```ruby
  Person.add_dynamic_column({
    :name => "telephone1",
    :type => "string",
    :length => 50,
    :required => true,
    :default => "Nothing yet"
  })
```

Then you can work with a Person instance as usual:

```ruby

  p1 = Person.create!(:name => "John Doe", :telephone1 => "555-23-12-78")
  p1.telephone1 # => "555-23-12-78"
  
  p2 = Person.create!(:name => "Freddie Mercury")
  p2.telephone1 # => "Nothing yet"
  p2.update_attributes!(:telephone1 => "I don't really know")
  p2.telephone1 # => "I don't really know"
  
```

Supported types are: `string`, `boolean`, `date`, `float`, `integer` and `text`.

Finally, you can remove dynamic columns from the database:

```ruby
  Person.del_dynamic_column("telephone1")
```

More documntation in progress.... excuse me.

## Testing DynamicModel

1. Configure the `test` section of the `config/database.yml` file as its done in rails.

2. Prepare the testing database:

    `RAILS_ENV='test' rake db:migrate`
    
3. Run the tests as usual:

    `RAILS_ENV='test' rake spec`
    
## TODO

* Validate and integrate with ActiveRecord validations
* Improve performance

## License

DynamicModel is released under the [MIT License](http://www.opensource.org/licenses/MIT).

