# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'scribble/version'

Gem::Specification.new do |spec|
  spec.name          = "scribble"
  spec.version       = Scribble::VERSION
  spec.authors       = ["Stefan Kroes"]
  spec.email         = ["stefan.kroes@lab01.nl"]
  spec.summary       = "Scribble is a customer facing template language similar to Liquid build in Ruby"
  spec.description   = "Scribble is a customer facing template language similar to Liquid. Scribble was written in Ruby and can be used in any Ruby or Ruby on Rails project. It takes a template file, consisting of text and Scribble tags and transforms it into text. Scribble can be used to transform any plain text format like HTML, Markdown, JSON, XML, etc. Customer facing means that it is safe to use Scribble to run/evaluate user provided templates."
  spec.homepage      = "https://github.com/stefankroes/scribble"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "parslet", "~> 1.6"
  spec.add_development_dependency "pry"
end
