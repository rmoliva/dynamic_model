dynamic_model
=============

[![Build Status](https://secure.travis-ci.org/rmoliva/dynamic_model.png)](http://travis-ci.org/rmoliva/dynamic_model)
[![Code Climate](https://codeclimate.com/github/rmoliva/dynamic_model.png)](https://codeclimate.com/github/rmoliva/dynamic_model)
[![Code Climate](https://codeclimate.com/github/rmoliva/dynamic_model/coverage.png)](https://codeclimate.com/github/rmoliva/dynamic_model)

dynamic_model is a gem that let you define the attributes of a model dynamically on the database.

The idea behind this is not to hard code the attributes of a model inside its code but in the database.
Obviously those attributes have limited functionality, but this approach helps change the definition of the application models without throwing a single line of code: simply adding or removing database rows.

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

In progress.... excuse me.


## Testing DynamicModel

1. Configure the `test` section of the `config/database.yml` file as its done in rails.

2. Prepare the testing database:

    `RAILS_ENV='test' rake db:migrate`
    
3. Run the tests as usual:

    `RAILS_ENV='test' rake spec`

## License

DynamicModel is released under the [MIT License](http://www.opensource.org/licenses/MIT).

