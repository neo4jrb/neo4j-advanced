module Neo4j
  module Advanced
    VERSION = "1.6.0.alpha.3"
    NEO_VERSION = "1.6.M02"
  end

  # make sure community, advanced and enterprise neo4j jar files have the same version
  if defined?(NEO_VERSION) && NEO_VERSION != Advanced::NEO_VERSION
    raise "Mismatch of Neo4j JAR versions. Already loaded JAR files #{NEO_VERSION}, neo4j-advanced: #{Advanced::NEO_VERSION}" 
  else
    NEO_VERSION = Advanced::NEO_VERSION
  end

end
