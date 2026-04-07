# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Splunk resource synthesis edge cases' do
  include Pangea::Testing::SynthesisTestHelpers

  let(:synth) { create_synthesizer }

  before { synth.extend(Pangea::Resources::Splunk) }

  # ── Boolean attribute nil-omission ──────────────────────────────────
  # Catches: boolean false being incorrectly omitted (falsy vs nil confusion)

  describe 'boolean attribute handling' do
    it 'includes disabled=false in HEC synthesis (false is not nil)' do
      synth.splunk_inputs_http_event_collector(:hec, name: 'test', disabled: false)
      result = normalize_synthesis(synth.synthesis)
      config = result.dig('resource', 'splunk_inputs_http_event_collector', 'hec')
      expect(config).to have_key('disabled')
      expect(config['disabled']).to eq(false)
    end

    it 'omits disabled when nil in HEC synthesis' do
      synth.splunk_inputs_http_event_collector(:hec, name: 'test')
      result = normalize_synthesis(synth.synthesis)
      config = result.dig('resource', 'splunk_inputs_http_event_collector', 'hec')
      expect(config).not_to have_key('disabled')
    end

    it 'includes use_ack=false in HEC synthesis' do
      synth.splunk_inputs_http_event_collector(:hec, name: 'test', use_ack: false)
      result = normalize_synthesis(synth.synthesis)
      config = result.dig('resource', 'splunk_inputs_http_event_collector', 'hec')
      expect(config).to have_key('use_ack')
      expect(config['use_ack']).to eq(false)
    end

    it 'includes is_scheduled=false in saved search synthesis' do
      synth.splunk_saved_searches(:ss, name: 'test', search: 'q', is_scheduled: false)
      result = normalize_synthesis(synth.synthesis)
      config = result.dig('resource', 'splunk_saved_searches', 'ss')
      expect(config).to have_key('is_scheduled')
      expect(config['is_scheduled']).to eq(false)
    end

    it 'includes is_visible=false in saved search synthesis' do
      synth.splunk_saved_searches(:ss, name: 'test', search: 'q', is_visible: false)
      result = normalize_synthesis(synth.synthesis)
      config = result.dig('resource', 'splunk_saved_searches', 'ss')
      expect(config).to have_key('is_visible')
      expect(config['is_visible']).to eq(false)
    end

    it 'includes visible=false in apps local synthesis' do
      synth.splunk_apps_local(:app, name: 'test', visible: false)
      result = normalize_synthesis(synth.synthesis)
      config = result.dig('resource', 'splunk_apps_local', 'app')
      expect(config).to have_key('visible')
      expect(config['visible']).to eq(false)
    end

    it 'includes update=false in apps local synthesis' do
      synth.splunk_apps_local(:app, name: 'test', update: false)
      result = normalize_synthesis(synth.synthesis)
      config = result.dig('resource', 'splunk_apps_local', 'app')
      expect(config).to have_key('update')
      expect(config['update']).to eq(false)
    end
  end

  # ── map_present nil-omission ────────────────────────────────────────
  # Catches: nil values leaking into synthesized config (would break Terraform)

  describe 'map_present attribute omission' do
    it 'omits nil optional string attrs from splunk_indexes synthesis' do
      synth.splunk_indexes(:idx, name: 'test')
      result = normalize_synthesis(synth.synthesis)
      config = result.dig('resource', 'splunk_indexes', 'idx')
      %w[cold_path cold_to_frozen_dir datatype home_path thawed_path].each do |attr|
        expect(config).not_to have_key(attr), "Expected '#{attr}' to be omitted when nil"
      end
    end

    it 'omits nil optional integer attrs from splunk_indexes synthesis' do
      synth.splunk_indexes(:idx, name: 'test')
      result = normalize_synthesis(synth.synthesis)
      config = result.dig('resource', 'splunk_indexes', 'idx')
      %w[frozen_time_period_in_secs max_data_size_mb max_total_data_size_mb max_warm_db_count].each do |attr|
        expect(config).not_to have_key(attr), "Expected '#{attr}' to be omitted when nil"
      end
    end

    it 'omits nil optional attrs from HEC synthesis' do
      synth.splunk_inputs_http_event_collector(:hec, name: 'test')
      result = normalize_synthesis(synth.synthesis)
      config = result.dig('resource', 'splunk_inputs_http_event_collector', 'hec')
      %w[index indexes source sourcetype].each do |attr|
        expect(config).not_to have_key(attr), "Expected '#{attr}' to be omitted when nil"
      end
    end

    it 'omits nil optional attrs from saved searches synthesis' do
      synth.splunk_saved_searches(:ss, name: 'test', search: 'q')
      result = normalize_synthesis(synth.synthesis)
      config = result.dig('resource', 'splunk_saved_searches', 'ss')
      %w[action_email_to actions alert_comparator alert_threshold alert_type
         cron_schedule description dispatch_earliest_time dispatch_latest_time].each do |attr|
        expect(config).not_to have_key(attr), "Expected '#{attr}' to be omitted when nil"
      end
    end

    it 'omits nil optional attrs from apps local synthesis' do
      synth.splunk_apps_local(:app, name: 'test')
      result = normalize_synthesis(synth.synthesis)
      config = result.dig('resource', 'splunk_apps_local', 'app')
      %w[auth explicit_appname label].each do |attr|
        expect(config).not_to have_key(attr), "Expected '#{attr}' to be omitted when nil"
      end
    end
  end

  # ── Resource reference completeness ─────────────────────────────────
  # Catches: missing output keys or wrong interpolation patterns

  describe 'resource reference output completeness' do
    it 'returns all declared outputs for splunk_indexes' do
      ref = synth.splunk_indexes(:idx, name: 'test')
      expect(ref).to be_a(Pangea::Resources::ResourceReference)
      expect(ref.outputs).to include(
        id: '${splunk_indexes.idx.id}',
        name: '${splunk_indexes.idx.name}'
      )
    end

    it 'returns all declared outputs for splunk_inputs_http_event_collector' do
      ref = synth.splunk_inputs_http_event_collector(:hec, name: 'test')
      expect(ref.outputs).to include(
        id: '${splunk_inputs_http_event_collector.hec.id}',
        name: '${splunk_inputs_http_event_collector.hec.name}',
        token: '${splunk_inputs_http_event_collector.hec.token}'
      )
    end

    it 'returns all declared outputs for splunk_saved_searches' do
      ref = synth.splunk_saved_searches(:ss, name: 'test', search: 'q')
      expect(ref.outputs).to include(
        id: '${splunk_saved_searches.ss.id}',
        name: '${splunk_saved_searches.ss.name}'
      )
    end

    it 'returns all declared outputs for splunk_apps_local' do
      ref = synth.splunk_apps_local(:app, name: 'test')
      expect(ref.outputs).to include(
        id: '${splunk_apps_local.app.id}',
        name: '${splunk_apps_local.app.name}',
        version: '${splunk_apps_local.app.version}'
      )
    end

    it 'preserves resource_attributes in the reference' do
      ref = synth.splunk_indexes(:idx, name: 'test-index', datatype: 'event')
      expect(ref.resource_attributes[:name]).to eq('test-index')
      expect(ref.resource_attributes[:datatype]).to eq('event')
    end

    it 'sets correct type on all resource references' do
      ref_idx = synth.splunk_indexes(:a, name: 'a')
      ref_hec = synth.splunk_inputs_http_event_collector(:b, name: 'b')
      ref_ss = synth.splunk_saved_searches(:c, name: 'c', search: 'q')
      ref_app = synth.splunk_apps_local(:d, name: 'd')

      expect(ref_idx.type).to eq('splunk_indexes')
      expect(ref_hec.type).to eq('splunk_inputs_http_event_collector')
      expect(ref_ss.type).to eq('splunk_saved_searches')
      expect(ref_app.type).to eq('splunk_apps_local')
    end
  end

  # ── Multi-resource isolation ────────────────────────────────────────
  # Catches: resource name collisions, config bleed between resources

  describe 'multi-resource isolation' do
    it 'supports multiple resources of the same type with distinct names' do
      synth.splunk_indexes(:idx1, name: 'logs')
      synth.splunk_indexes(:idx2, name: 'metrics')
      result = normalize_synthesis(synth.synthesis)

      expect(result.dig('resource', 'splunk_indexes', 'idx1', 'name')).to eq('logs')
      expect(result.dig('resource', 'splunk_indexes', 'idx2', 'name')).to eq('metrics')
    end

    it 'does not let one resource config bleed into another' do
      synth.splunk_indexes(:idx1, name: 'idx1', datatype: 'event')
      synth.splunk_indexes(:idx2, name: 'idx2')
      result = normalize_synthesis(synth.synthesis)

      expect(result.dig('resource', 'splunk_indexes', 'idx1', 'datatype')).to eq('event')
      expect(result.dig('resource', 'splunk_indexes', 'idx2')).not_to have_key('datatype')
    end

    it 'isolates resources of different types' do
      synth.splunk_indexes(:shared_name, name: 'shared')
      synth.splunk_apps_local(:shared_name, name: 'shared')
      result = normalize_synthesis(synth.synthesis)

      expect(result.dig('resource', 'splunk_indexes', 'shared_name')).not_to be_nil
      expect(result.dig('resource', 'splunk_apps_local', 'shared_name')).not_to be_nil
    end
  end

  # ── Special characters and edge-case values ─────────────────────────
  # Catches: encoding issues, empty string handling, special chars in names

  describe 'edge case attribute values' do
    it 'handles names with hyphens and underscores' do
      synth.splunk_indexes(:test, name: 'my-index_v2')
      result = normalize_synthesis(synth.synthesis)
      expect(result.dig('resource', 'splunk_indexes', 'test', 'name')).to eq('my-index_v2')
    end

    it 'handles empty string for optional attributes' do
      synth.splunk_saved_searches(:test, name: 'test', search: '', description: '')
      result = normalize_synthesis(synth.synthesis)
      config = result.dig('resource', 'splunk_saved_searches', 'test')
      expect(config['search']).to eq('')
    end

    it 'handles large integer values for index size' do
      synth.splunk_indexes(:test, name: 'big', max_total_data_size_mb: 10_000_000)
      result = normalize_synthesis(synth.synthesis)
      expect(result.dig('resource', 'splunk_indexes', 'test', 'max_total_data_size_mb')).to eq(10_000_000)
    end

    it 'handles zero for integer attributes' do
      synth.splunk_indexes(:test, name: 'zero', frozen_time_period_in_secs: 0)
      result = normalize_synthesis(synth.synthesis)
      expect(result.dig('resource', 'splunk_indexes', 'test', 'frozen_time_period_in_secs')).to eq(0)
    end

    it 'handles SPL search strings with special characters' do
      search_query = 'index=main sourcetype="access_combined" status>=400 | stats count by host, status | where count > 100'
      synth.splunk_saved_searches(:test, name: 'complex', search: search_query)
      result = normalize_synthesis(synth.synthesis)
      expect(result.dig('resource', 'splunk_saved_searches', 'test', 'search')).to eq(search_query)
    end

    it 'handles dispatch attributes with time boundaries' do
      synth.splunk_saved_searches(:test,
        name: 'timed', search: 'q',
        dispatch_earliest_time: '-24h@h',
        dispatch_latest_time: 'now',
        dispatch_buckets: 0,
        dispatch_max_count: 0
      )
      result = normalize_synthesis(synth.synthesis)
      config = result.dig('resource', 'splunk_saved_searches', 'test')
      expect(config['dispatch_earliest_time']).to eq('-24h@h')
      expect(config['dispatch_latest_time']).to eq('now')
      expect(config['dispatch_buckets']).to eq(0)
      expect(config['dispatch_max_count']).to eq(0)
    end
  end

  # ── HEC-specific edge cases ─────────────────────────────────────────
  # Catches: indexes array serialization issues

  describe 'HEC indexes array handling' do
    it 'synthesizes with single-element indexes array' do
      synth.splunk_inputs_http_event_collector(:hec, name: 'test', indexes: ['main'])
      result = normalize_synthesis(synth.synthesis)
      config = result.dig('resource', 'splunk_inputs_http_event_collector', 'hec')
      expect(config['indexes']).to eq(['main'])
    end

    it 'synthesizes with multi-element indexes array' do
      synth.splunk_inputs_http_event_collector(:hec,
        name: 'test', indexes: ['main', 'summary', 'internal']
      )
      result = normalize_synthesis(synth.synthesis)
      config = result.dig('resource', 'splunk_inputs_http_event_collector', 'hec')
      expect(config['indexes']).to eq(['main', 'summary', 'internal'])
    end
  end
end
