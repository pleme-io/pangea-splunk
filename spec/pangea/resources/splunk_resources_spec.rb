# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'pangea-splunk provider' do
  include Pangea::Testing::SynthesisTestHelpers

  # ── Load Tests ─────────────────────────────────────────────────────────

  describe 'gem loading' do
    it 'loads pangea-splunk without error' do
      expect(defined?(Pangea::Resources::Splunk)).to be_truthy
    end

    it 'defines all resource modules' do
      expect(defined?(Pangea::Resources::SplunkIndexes)).to be_truthy
      expect(defined?(Pangea::Resources::SplunkInputsHttpEventCollector)).to be_truthy
      expect(defined?(Pangea::Resources::SplunkSavedSearches)).to be_truthy
      expect(defined?(Pangea::Resources::SplunkAppsLocal)).to be_truthy
    end

    it 'registers Splunk module in ResourceRegistry' do
      registry_modules = Pangea::ResourceRegistry.registered_modules
      expect(registry_modules).to include(Pangea::Resources::Splunk)
    end
  end

  # ── Synthesis Tests ────────────────────────────────────────────────────

  let(:synth) { create_synthesizer }

  describe 'splunk_indexes' do
    before { synth.extend(Pangea::Resources::Splunk) }

    let(:required_attrs) do
      { name: 'main_events' }
    end

    it 'synthesizes with required attributes' do
      synth.splunk_indexes(:test, required_attrs)
      result = normalize_synthesis(synth.synthesis)
      config = result.dig('resource', 'splunk_indexes', 'test')
      expect(config).not_to be_nil
      expect(config['name']).to eq('main_events')
    end

    it 'returns ResourceReference with correct outputs' do
      ref = synth.splunk_indexes(:test, required_attrs)
      expect(ref).to be_a(Pangea::Resources::ResourceReference)
      expect(ref.type).to eq('splunk_indexes')
      expect(ref.outputs[:id]).to eq('${splunk_indexes.test.id}')
      expect(ref.outputs[:name]).to eq('${splunk_indexes.test.name}')
    end

    it 'includes optional attributes when provided' do
      synth.splunk_indexes(:test, required_attrs.merge(
        datatype: 'event',
        max_total_data_size_mb: 500_000,
        frozen_time_period_in_secs: 86_400 * 90,
      ))
      result = normalize_synthesis(synth.synthesis)
      config = result.dig('resource', 'splunk_indexes', 'test')
      expect(config['datatype']).to eq('event')
      expect(config['max_total_data_size_mb']).to eq(500_000)
      expect(config['frozen_time_period_in_secs']).to eq(86_400 * 90)
    end

    it 'omits optional attributes when nil' do
      synth.splunk_indexes(:test, required_attrs)
      result = normalize_synthesis(synth.synthesis)
      config = result.dig('resource', 'splunk_indexes', 'test')
      expect(config).not_to have_key('datatype')
      expect(config).not_to have_key('max_total_data_size_mb')
    end

    it 'rejects unknown attribute keys' do
      expect {
        synth.splunk_indexes(:test, required_attrs.merge(bad_key: 'x'))
      }.to raise_error(ArgumentError, /unknown attributes.*bad_key/)
    end
  end

  describe 'splunk_inputs_http_event_collector' do
    before { synth.extend(Pangea::Resources::Splunk) }

    let(:required_attrs) do
      { name: 'app-events' }
    end

    it 'synthesizes with required attributes' do
      synth.splunk_inputs_http_event_collector(:test, required_attrs)
      result = normalize_synthesis(synth.synthesis)
      config = result.dig('resource', 'splunk_inputs_http_event_collector', 'test')
      expect(config).not_to be_nil
      expect(config['name']).to eq('app-events')
    end

    it 'returns ResourceReference with token output' do
      ref = synth.splunk_inputs_http_event_collector(:test, required_attrs)
      expect(ref.outputs[:token]).to eq('${splunk_inputs_http_event_collector.test.token}')
    end

    it 'includes optional attributes' do
      synth.splunk_inputs_http_event_collector(:test, required_attrs.merge(
        index: 'main',
        sourcetype: 'json',
        disabled: false,
        use_ack: true,
      ))
      result = normalize_synthesis(synth.synthesis)
      config = result.dig('resource', 'splunk_inputs_http_event_collector', 'test')
      expect(config['index']).to eq('main')
      expect(config['sourcetype']).to eq('json')
      expect(config['disabled']).to eq(false)
      expect(config['use_ack']).to eq(true)
    end
  end

  describe 'splunk_saved_searches' do
    before { synth.extend(Pangea::Resources::Splunk) }

    let(:required_attrs) do
      { name: 'error-search', search: 'index=main level=ERROR | stats count by host' }
    end

    it 'synthesizes with required attributes' do
      synth.splunk_saved_searches(:test, required_attrs)
      result = normalize_synthesis(synth.synthesis)
      config = result.dig('resource', 'splunk_saved_searches', 'test')
      expect(config).not_to be_nil
      expect(config['name']).to eq('error-search')
      expect(config['search']).to include('level=ERROR')
    end

    it 'returns ResourceReference' do
      ref = synth.splunk_saved_searches(:test, required_attrs)
      expect(ref).to be_a(Pangea::Resources::ResourceReference)
      expect(ref.type).to eq('splunk_saved_searches')
    end

    it 'includes scheduling attributes' do
      synth.splunk_saved_searches(:test, required_attrs.merge(
        is_scheduled: true,
        cron_schedule: '*/5 * * * *',
        description: 'Monitors error rates',
      ))
      result = normalize_synthesis(synth.synthesis)
      config = result.dig('resource', 'splunk_saved_searches', 'test')
      expect(config['is_scheduled']).to eq(true)
      expect(config['cron_schedule']).to eq('*/5 * * * *')
      expect(config['description']).to eq('Monitors error rates')
    end

    it 'includes alert attributes' do
      synth.splunk_saved_searches(:test, required_attrs.merge(
        alert_type: 'number of events',
        alert_comparator: 'greater than',
        alert_threshold: '100',
      ))
      result = normalize_synthesis(synth.synthesis)
      config = result.dig('resource', 'splunk_saved_searches', 'test')
      expect(config['alert_type']).to eq('number of events')
      expect(config['alert_comparator']).to eq('greater than')
      expect(config['alert_threshold']).to eq('100')
    end
  end

  describe 'splunk_apps_local' do
    before { synth.extend(Pangea::Resources::Splunk) }

    let(:required_attrs) do
      { name: 'my-app' }
    end

    it 'synthesizes with required attributes' do
      synth.splunk_apps_local(:test, required_attrs)
      result = normalize_synthesis(synth.synthesis)
      config = result.dig('resource', 'splunk_apps_local', 'test')
      expect(config).not_to be_nil
      expect(config['name']).to eq('my-app')
    end

    it 'returns ResourceReference with version output' do
      ref = synth.splunk_apps_local(:test, required_attrs)
      expect(ref.outputs[:version]).to eq('${splunk_apps_local.test.version}')
    end

    it 'includes optional attributes' do
      synth.splunk_apps_local(:test, required_attrs.merge(
        label: 'My Application',
        visible: true,
        update: false,
      ))
      result = normalize_synthesis(synth.synthesis)
      config = result.dig('resource', 'splunk_apps_local', 'test')
      expect(config['label']).to eq('My Application')
      expect(config['visible']).to eq(true)
      expect(config['update']).to eq(false)
    end
  end

  # ── Cross-Resource Tests ───────────────────────────────────────────────

  describe 'Splunk aggregator module' do
    before { synth.extend(Pangea::Resources::Splunk) }

    it 'exposes all resource methods through single module' do
      expect(synth).to respond_to(:splunk_indexes)
      expect(synth).to respond_to(:splunk_inputs_http_event_collector)
      expect(synth).to respond_to(:splunk_saved_searches)
      expect(synth).to respond_to(:splunk_apps_local)
    end

    it 'synthesizes multiple resources in a single synthesizer' do
      synth.splunk_indexes(:idx, { name: 'app-logs' })
      synth.splunk_inputs_http_event_collector(:hec, { name: 'app-input' })
      synth.splunk_saved_searches(:search, { name: 'error-alert', search: 'index=main ERROR' })
      result = normalize_synthesis(synth.synthesis)

      expect(result.dig('resource', 'splunk_indexes', 'idx')).not_to be_nil
      expect(result.dig('resource', 'splunk_inputs_http_event_collector', 'hec')).not_to be_nil
      expect(result.dig('resource', 'splunk_saved_searches', 'search')).not_to be_nil
    end
  end
end
