# -*- encoding: utf-8 -*-
require 'rubygems' unless defined? Gem
require File.dirname(__FILE__) + "/lib/seeder/version"

Gem::Specification.new do |s|
  s.name        = "seeder"
  s.version     = Seeder::VERSION
  s.authors     = ["Barun Singh", "Gabriel Horner"]
  s.email       = "bsingh@wegowise.com"
  s.homepage    = "http://github.com/wegowise/seeder"
  s.summary = "Seed your data"
  s.description =  "Keep your app's seed data in one file and update it easily, while respecting key constraints"
  s.required_rubygems_version = ">= 1.3.6"
  s.files = Dir.glob(%w[{lib,spec}/**/*.rb [A-Z]*.{txt,rdoc,md} *.gemspec]) + %w{Rakefile}
  s.extra_rdoc_files = ["README.md", "LICENSE.txt"]
  s.license = 'MIT'

  s.add_development_dependency('rspec-rails', '~> 3.0')
  s.add_development_dependency('mysql2', '~> 0.3')
  s.add_development_dependency('activerecord', '>= 3.2', '< 5.0')
end
