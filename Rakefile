begin
  require "hanna/rdoctask"
rescue LoadError
  require "rake/rdoctask"
end

require "rake/testtask"

Rake::RDocTask.new do |rd|
  rd.main = "README.rdoc"
  rd.title = "API Documentation for Protest"
  rd.rdoc_files.include("README.rdoc", "LICENSE", "lib/**/*.rb")
  rd.rdoc_dir = "doc"
end

begin
  require "mg"
  MG.new("protest.gemspec")
rescue LoadError
end

Rake::TestTask.new

task :default => :test
