require File.join(File.dirname(__FILE__), 'spec_helper')

describe Neo4j, :type => :transactional do

  after(:each) { Neo4j.threadlocal_ref_node = nil }

  it "#management returns by default a management for Primitives" do
    (Neo4j.management.get_number_of_node_ids_in_use > 0).should be true
  end
end
