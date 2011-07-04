# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'ordered-active-record/version'

Gem::Specification.new do |s|
  s.name          = 'ordered-active-record'
  s.version       = OrderedActiveRecord::VERSION
  s.authors       = ['Walter Horstman']
  s.email         = ['walter.horstman@itonrails.com']
  s.homepage      = 'http://github.com/walterhorstman/ordered-active-record'
  s.summary       = 'Lightweight ordering of models in RubyOnRails 3'
  s.description   = 'This gem allows you to have ordered models. It is like the old acts_as_list, but very lightweight and with an optimized SQL syntax.'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_dependency 'activerecord', '~> 3'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'sqlite3'
end