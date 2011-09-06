# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "shitdb/version"

Gem::Specification.new do |s|
  s.name        = "shitdb"
  s.version     = ShitDB::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Josep M. Bach"]
  s.email       = ["josep.m.bach@gmail.com"]
  s.homepage    = "http://github.com/txus/shitdb"
  s.summary     = %q{Document-oriented database written in pure Ruby with lame performance as a key feature}
  s.description = %q{Document-oriented database written in pure Ruby with lame performance as a key feature}

  s.rubyforge_project = "shitdb"

  s.add_development_dependency 'minitest'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'purdytest'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
