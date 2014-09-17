require 'yaml'
require 'bundler'
require 'bundler/setup'
Bundler::GemHelper.install_tasks
require "active_record"
require "logger"

module Rails
  def self.root
    File.dirname(__FILE__)
  end
end

unless Rails.respond_to? :env
require 'active_support/string_inquirer'
  def Rails.env
    @_env ||= ActiveSupport::StringInquirer.new(ENV["RAILS_ENV"] || ENV["RACK_ENV"] || "development")
  end
end

task :environment do
  ActiveRecord::Base.establish_connection(YAML.load_file(File.join(File.dirname(__FILE__), "config", "database.yml"))[ENV['RAILS_ENV']])
  ActiveRecord::Base.logger = Logger.new(File.open(File.join(File.dirname(__FILE__), "log", "database.log"), 'a'))
end
 
task :console do
  require 'irb'
  require 'irb/completion'
  require File.join(File.dirname(__FILE__), "lib", "dynamic_model")
  ARGV.clear
  IRB.start
end
 
namespace :db do
  desc 'Create the MySQL database'
  task :create do
    config = YAML.load_file(File.join(File.dirname(__FILE__), "config", "database.yml"))[ENV["RAILS_ENV"]]
    %x( mysql -u #{config['username']} -p#{config['password']} -e "create DATABASE #{config['database']} DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_unicode_ci ")
  end

  desc 'Drop the MySQL database'
  task :drop do
    config = YAML.load_file(File.join(File.dirname(__FILE__), "config", "database.yml"))[ENV["RAILS_ENV"]]
    %x( mysqladmin --user=#{config['username']} -f drop #{config['database']} )
  end

  desc 'Rebuild the MySQL database'
  task :rebuild => [:drop, :build]
  
  desc "Migrate the database through scripts in db/migrate. Target specific version with VERSION=x"
  task :migrate => :environment do
    # Copiar la plantilla de migracion
    [{
      :from => File.join(File.dirname(__FILE__), "lib", "generators", "dynamic_model", "templates", "create_dynamic_model_tables.rb"),
      :to => File.join(File.dirname(__FILE__), "db", "migrate", "001_create_dynamic_model_tables.rb")
    }, {
      :from => File.join(File.dirname(__FILE__), "lib", "generators", "dynamic_model", "templates", "create_test_table.rb"),
      :to => File.join(File.dirname(__FILE__), "db", "migrate", "002_create_test_table.rb")
    }].each do |data|
      FileUtils.cp data[:from], data[:to]
    end
    ActiveRecord::Migrator.migrate('db/migrate', ENV["VERSION"] ? ENV["VERSION"].to_i : nil )
  end
end

require 'rspec/core/rake_task'
desc 'Run DynamicModel specs for the RSpec helper.'
RSpec::Core::RakeTask.new(:spec)

desc 'Default: run all available test suites'
task :default => [:prepare, :spec]
