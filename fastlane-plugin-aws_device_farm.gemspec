# rubocop:disable Style/FileName
# coding: utf-8

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/aws_device_farm/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-aws_device_farm'
  spec.version       = Fastlane::AwsDeviceFarm::VERSION
  spec.version = "#{spec.version}-alpha-#{ENV['TRAVIS_BUILD_NUMBER']}" if ENV['TRAVIS']
  spec.author        = 'Helmut Januschka'
  spec.email         = 'helmut@januschka.com'

  spec.summary       = 'Run UI Tests on AWS Devicefarm'
  spec.homepage      = "https://github.com/hjanuschka/fastlane-plugin-aws_device_farm"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'aws-sdk'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'fastlane', '>= 1.105.0'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
end
