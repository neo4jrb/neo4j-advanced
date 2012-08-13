require "bundler/gem_tasks"

def download_folder
  abort "Please create a #{File.expand_path('tmp')} folder and copy the neo4j advanced gz/tar file downloaded from http://neo4j.org/download" unless File.directory?('tmp')
  Dir.new('tmp')
end

def tar_file
  download_folder.entries.find { |x| x =~ /gz$/ || x =~ /tar$/}.tap do |f|
    abort "expected a neo4j .gz/.tar file in folder #{File.expand_path(download_folder.path)}"  unless f
  end
end

def source_file
  File.expand_path("./tmp/#{tar_file}")
end

def unpack_lib_dir
  dir = tar_file.gsub('-unix.tar.gz', '')
  dir = dir.gsub('-unix.tar', '')
  File.expand_path("./tmp/#{dir}/lib")
end

def jar_files_to_copy
  Dir.new(unpack_lib_dir).entries.find_all {|x| x =~ /\.jar/}
end

desc "Delete old Jar files"
task :delete_old_jar do
  root = File.expand_path("./lib/neo4j-advanced/jars")
  files = Dir.new(root).entries.find_all{|f| f =~ /\.jar/}
  files.each do |file|
    system "rm #{root}/#{file}"
  end
end

def include_jar?(file)
  include_only = %w[neo4j-advanced neo4j-management]
  include_only.each do |i|
    return true if file.start_with?(i) 
  end
  false
end

desc "Upgrade using downloaded ...tar.gz file in ./tmp"
task :upgrade => [:delete_old_jar] do
  system "cd tmp; tar xf #{source_file}"
  jars = File.expand_path("./lib/neo4j-advanced/jars")
  jar_files_to_copy.each {|f| system "cp #{unpack_lib_dir}/#{f} #{jars}" if include_jar?(f)}
end