require "rubygems" unless defined? Gem
require File.dirname(__FILE__) + "/lib/seeder/version"

Gem::Specification.new do |s|
  s.name = "seeder"
  s.version = Seeder::VERSION
  s.authors = ["Barun Singh"]
  s.email = "bsingh@wegowise.com"
  s.homepage = "http://github.com/wegowise/seeder"
  s.summary = "Manage seed data for your Rails app"
  s.description = "Keep your app's seed data in one file and update it easily"
  s.required_rubygems_version = ">= 1.3.6"
  s.files = `git ls-files`.split("\n")
  s.extra_rdoc_files = ["README.md", "LICENSE.txt"]
  s.license = "MIT"

  s.add_dependency("activerecord", ">= 5.2", "< 7.2")

  s.add_development_dependency("mysql2", ">= 0.4.4", "< 0.6.0")
  s.add_development_dependency("rspec", "~> 3.0")
  s.add_development_dependency("rake", ">= 10.4")
  s.add_development_dependency("standard")
end
