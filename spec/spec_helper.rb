require 'rubygems'
require "bundler/setup"
require 'rspec'
require 'fileutils'
require 'tmpdir'

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "..", "lib")

require 'neo4j'
require 'neo4j-advanced'

require 'logger'
Neo4j::Config[:logger_level] = Logger::ERROR
Neo4j::Config[:storage_path] = File.join(Dir.tmpdir, "neo4j-rspec-db")
Neo4j::Config[:debug_java] = true

Neo4j::Config[:identity_map] = (ENV['IDENTITY_MAP'] == "true") # faster tests
Neo4j::IdentityMap.enabled = (ENV['IDENTITY_MAP'] == "true") # this is normally set in the rails rack middleware

def rm_db_storage
  FileUtils.rm_rf Neo4j::Config[:storage_path]
  raise "Can't delete db" if File.exist?(Neo4j::Config[:storage_path])
end

def finish_tx
  return unless @tx
  @tx.success
  @tx.finish
  @tx = nil
end

def new_tx
  finish_tx if @tx
  @tx = Neo4j::Transaction.new
end

# ensure the translations get picked up for tests
I18n.load_path += Dir[File.join(File.dirname(__FILE__), '..', 'config', 'locales', '*.{rb,yml}')]

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

# load all fixture classes
Dir["#{File.dirname(__FILE__)}/fixture/**/*.rb"].each {|f| require f}

# set database storage location
Neo4j::Config[:storage_path] = File.join(Dir.tmpdir, 'neo4j-rspec-tests')

RSpec.configure do |c|
  $name_counter = 0

  c.filter_run_excluding :identity_map => true if not Neo4j::IdentityMap.enabled

  c.before(:each, :type => :transactional) do
    new_tx
  end

  c.after(:each, :type => :transactional) do
    finish_tx
    Neo4j::Rails::Model.close_lucene_connections
  end

  c.after(:each) do
    finish_tx
    Neo4j::Rails::Model.close_lucene_connections
    Neo4j::Transaction.run do
      Neo4j::Index::IndexerRegistry.delete_all_indexes
    end
    Neo4j::Transaction.run do
      Neo4j.threadlocal_ref_node = Neo4j::Node.new :name => "ref_#{$name_counter}"
      $name_counter += 1
    end
  end

  c.before(:all) do
    rm_db_storage unless Neo4j.running?
  end

end


