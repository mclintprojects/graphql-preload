# coding: utf-8

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "graphql/preload/version"

Gem::Specification.new do |spec|
  spec.name = "graphql-preload"
  spec.version = GraphQL::Preload::VERSION
  spec.authors = ["Ryan Foster, Etienne Tripier", "Clinton Mbah"]
  spec.email = ["clintonmbah44@gmail.com"]

  spec.summary = "Preload ActiveRecord associations with graphql-batch"
  spec.homepage = "https://github.com/ConsultingMD/graphql-preload"
  spec.license = "MIT"

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "activerecord", ">= 7.0"
  spec.add_runtime_dependency "graphql", ">= 2.3.21"
  spec.add_runtime_dependency "graphql-batch", "~> 0.6"
  spec.add_runtime_dependency "promise.rb", "~> 0.7"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-sqlimit"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "yard"
  spec.add_development_dependency "byebug"
end
