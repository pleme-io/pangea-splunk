# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
  add_filter '/vendor/'
  track_files 'lib/**/*.rb'
end

lib_path = File.expand_path('../lib', __dir__)
$LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include?(lib_path)

require 'rspec'

begin
  require 'dry-types'
  require 'dry-struct'
  require 'terraform-synthesizer'
  require 'json'
rescue LoadError => e
  puts "Warning: Could not load dependency: #{e.message}"
end

begin
  require 'pangea-splunk'
  Splunk = Pangea::Resources::Splunk unless defined?(Splunk)
rescue LoadError => e
  puts "Warning: Could not load pangea-splunk: #{e.message}"
end

require 'pangea/testing'

Dir[File.join(__dir__, 'support', '**', '*.rb')].each { |f| require f }

Pangea::Testing::SpecSetup.configure!
