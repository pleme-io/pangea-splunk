# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Splunk module registration and version' do
  # ── Version module ──────────────────────────────────────────────────
  # Catches: version drift or missing version constant

  describe 'PangeaSplunk::VERSION' do
    it 'is defined' do
      expect(defined?(PangeaSplunk::VERSION)).to be_truthy
    end

    it 'follows semver format' do
      expect(PangeaSplunk::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
    end

    it 'is frozen' do
      expect(PangeaSplunk::VERSION).to be_frozen
    end
  end

  # ── Module hierarchy ────────────────────────────────────────────────
  # Catches: broken includes, missing module ancestors

  describe 'Splunk aggregator module includes' do
    it 'includes SplunkIndexes' do
      expect(Pangea::Resources::Splunk.ancestors).to include(Pangea::Resources::SplunkIndexes)
    end

    it 'includes SplunkInputsHttpEventCollector' do
      expect(Pangea::Resources::Splunk.ancestors).to include(Pangea::Resources::SplunkInputsHttpEventCollector)
    end

    it 'includes SplunkSavedSearches' do
      expect(Pangea::Resources::Splunk.ancestors).to include(Pangea::Resources::SplunkSavedSearches)
    end

    it 'includes SplunkAppsLocal' do
      expect(Pangea::Resources::Splunk.ancestors).to include(Pangea::Resources::SplunkAppsLocal)
    end
  end

  # ── ResourceRegistry registration ──────────────────────────────────
  # Catches: module not auto-registering on load

  describe 'ResourceRegistry' do
    it 'has Splunk module registered' do
      expect(Pangea::ResourceRegistry.registered?(Pangea::Resources::Splunk)).to be true
    end

    it 'registered_modules includes Splunk' do
      expect(Pangea::ResourceRegistry.registered_modules).to include(Pangea::Resources::Splunk)
    end
  end

  # ── Gem entry point loading ─────────────────────────────────────────
  # Catches: require order issues, missing require_relative

  describe 'gem entry point' do
    it 'loads all type modules' do
      expect(defined?(Pangea::Resources::Splunk::Types)).to be_truthy
    end

    it 'loads IndexesAttributes struct' do
      expect(defined?(Pangea::Resources::Splunk::Types::IndexesAttributes)).to be_truthy
    end

    it 'loads InputsHttpEventCollectorAttributes struct' do
      expect(defined?(Pangea::Resources::Splunk::Types::InputsHttpEventCollectorAttributes)).to be_truthy
    end

    it 'loads SavedSearchesAttributes struct' do
      expect(defined?(Pangea::Resources::Splunk::Types::SavedSearchesAttributes)).to be_truthy
    end

    it 'loads AppsLocalAttributes struct' do
      expect(defined?(Pangea::Resources::Splunk::Types::AppsLocalAttributes)).to be_truthy
    end
  end
end
