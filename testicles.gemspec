Gem::Specification.new do |s|
  s.name    = "testicles"
  s.version = "0.1"
  s.date    = "2009-09-11"

  s.description = "Testicles is a tiny, simple, and easy-to-extend test framework"
  s.summary     = s.description
  s.homepage    = "http://github.com/foca/testicles"

  s.authors = ["Nicolás Sanguinetti"]
  s.email   = "contacto@nicolassanguinetti.info"

  s.require_paths     = ["lib"]
  s.rubyforge_project = "testicles"
  s.has_rdoc          = true
  s.rubygems_version  = "1.3.1"

  s.files = %w[
.gitignore
LICENSE
README.rdoc
Rakefile
testicles.gemspec
lib/testicles.rb
lib/testicles/utils.rb
lib/testicles/utils/summaries.rb
lib/testicles/utils/colorful_output.rb
lib/testicles/test_case.rb
lib/testicles/tests.rb
lib/testicles/runner.rb
lib/testicles/report.rb
lib/testicles/reports.rb
lib/testicles/reports/progress.rb
lib/testicles/reports/documentation.rb
]
end
