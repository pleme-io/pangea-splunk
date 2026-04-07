# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Splunk Dry::Struct attribute validation' do
  # ── IndexesAttributes ───────────────────────────────────────────────
  # Catches: missing required `name`, wrong types for integers, invalid optional attrs

  describe Pangea::Resources::Splunk::Types::IndexesAttributes do
    it 'constructs with only the required name attribute' do
      attrs = described_class.new(name: 'test-index')
      expect(attrs.name).to eq('test-index')
    end

    it 'raises on missing required name' do
      expect { described_class.new({}) }.to raise_error(Dry::Struct::Error)
    end

    it 'accepts string keys via transform_keys' do
      attrs = described_class.new('name' => 'string-key-index')
      expect(attrs.name).to eq('string-key-index')
    end

    it 'accepts all optional integer attributes' do
      attrs = described_class.new(
        name: 'full-index',
        frozen_time_period_in_secs: 7_776_000,
        max_data_size_mb: 1024,
        max_total_data_size_mb: 500_000,
        max_warm_db_count: 300
      )
      expect(attrs.frozen_time_period_in_secs).to eq(7_776_000)
      expect(attrs.max_data_size_mb).to eq(1024)
      expect(attrs.max_total_data_size_mb).to eq(500_000)
      expect(attrs.max_warm_db_count).to eq(300)
    end

    it 'allows nil for optional string attributes' do
      attrs = described_class.new(name: 'test', datatype: nil, cold_path: nil)
      expect(attrs.datatype).to be_nil
      expect(attrs.cold_path).to be_nil
    end

    it 'accepts all optional string path attributes' do
      attrs = described_class.new(
        name: 'path-index',
        cold_path: '/opt/splunk/cold',
        home_path: '/opt/splunk/home',
        thawed_path: '/opt/splunk/thawed',
        cold_to_frozen_dir: '/archive/frozen'
      )
      expect(attrs.cold_path).to eq('/opt/splunk/cold')
      expect(attrs.home_path).to eq('/opt/splunk/home')
      expect(attrs.thawed_path).to eq('/opt/splunk/thawed')
      expect(attrs.cold_to_frozen_dir).to eq('/archive/frozen')
    end

    it 'defaults optional attributes to nil when omitted' do
      attrs = described_class.new(name: 'minimal')
      expect(attrs.datatype).to be_nil
      expect(attrs.max_data_size_mb).to be_nil
      expect(attrs.cold_path).to be_nil
    end
  end

  # ── InputsHttpEventCollectorAttributes ──────────────────────────────
  # Catches: invalid types for boolean fields, missing required name

  describe Pangea::Resources::Splunk::Types::InputsHttpEventCollectorAttributes do
    it 'constructs with only the required name' do
      attrs = described_class.new(name: 'hec-input')
      expect(attrs.name).to eq('hec-input')
    end

    it 'raises on missing name' do
      expect { described_class.new({}) }.to raise_error(Dry::Struct::Error)
    end

    it 'accepts boolean attributes' do
      attrs = described_class.new(name: 'hec', disabled: true, use_ack: false)
      expect(attrs.disabled).to eq(true)
      expect(attrs.use_ack).to eq(false)
    end

    it 'accepts array of strings for indexes' do
      attrs = described_class.new(name: 'hec', indexes: ['main', 'summary'])
      expect(attrs.indexes).to eq(['main', 'summary'])
    end

    it 'accepts empty array for indexes' do
      attrs = described_class.new(name: 'hec', indexes: [])
      expect(attrs.indexes).to eq([])
    end

    it 'allows all optional attributes to be nil' do
      attrs = described_class.new(name: 'minimal-hec')
      expect(attrs.disabled).to be_nil
      expect(attrs.index).to be_nil
      expect(attrs.indexes).to be_nil
      expect(attrs.source).to be_nil
      expect(attrs.sourcetype).to be_nil
      expect(attrs.use_ack).to be_nil
    end

    it 'accepts string keys via transform_keys' do
      attrs = described_class.new('name' => 'string-hec', 'index' => 'main')
      expect(attrs.name).to eq('string-hec')
      expect(attrs.index).to eq('main')
    end
  end

  # ── SavedSearchesAttributes ─────────────────────────────────────────
  # Catches: missing required search field, wrong type for integer dispatch fields

  describe Pangea::Resources::Splunk::Types::SavedSearchesAttributes do
    it 'constructs with required name and search' do
      attrs = described_class.new(name: 'my-search', search: 'index=main')
      expect(attrs.name).to eq('my-search')
      expect(attrs.search).to eq('index=main')
    end

    it 'raises on missing name' do
      expect { described_class.new(search: 'index=main') }.to raise_error(Dry::Struct::Error)
    end

    it 'raises on missing search' do
      expect { described_class.new(name: 'orphan') }.to raise_error(Dry::Struct::Error)
    end

    it 'raises on missing both required fields' do
      expect { described_class.new({}) }.to raise_error(Dry::Struct::Error)
    end

    it 'accepts integer dispatch attributes' do
      attrs = described_class.new(
        name: 'search', search: 'index=main',
        dispatch_buckets: 300,
        dispatch_max_count: 10_000
      )
      expect(attrs.dispatch_buckets).to eq(300)
      expect(attrs.dispatch_max_count).to eq(10_000)
    end

    it 'accepts all optional string attributes' do
      attrs = described_class.new(
        name: 'full-search', search: 'index=main ERROR',
        action_email_to: 'admin@example.com',
        actions: 'email',
        alert_comparator: 'greater than',
        alert_threshold: '100',
        alert_type: 'number of events',
        cron_schedule: '*/5 * * * *',
        description: 'Error monitor',
        dispatch_earliest_time: '-1h',
        dispatch_latest_time: 'now'
      )
      expect(attrs.action_email_to).to eq('admin@example.com')
      expect(attrs.actions).to eq('email')
      expect(attrs.cron_schedule).to eq('*/5 * * * *')
    end

    it 'accepts boolean scheduling attributes' do
      attrs = described_class.new(
        name: 'scheduled', search: 'index=main',
        disabled: false,
        is_scheduled: true,
        is_visible: true
      )
      expect(attrs.disabled).to eq(false)
      expect(attrs.is_scheduled).to eq(true)
      expect(attrs.is_visible).to eq(true)
    end

    it 'defaults all optional attributes to nil' do
      attrs = described_class.new(name: 's', search: 'q')
      expect(attrs.disabled).to be_nil
      expect(attrs.is_scheduled).to be_nil
      expect(attrs.is_visible).to be_nil
      expect(attrs.dispatch_buckets).to be_nil
      expect(attrs.cron_schedule).to be_nil
      expect(attrs.alert_type).to be_nil
    end
  end

  # ── AppsLocalAttributes ─────────────────────────────────────────────
  # Catches: missing required name, wrong type for boolean fields

  describe Pangea::Resources::Splunk::Types::AppsLocalAttributes do
    it 'constructs with only the required name' do
      attrs = described_class.new(name: 'my-app')
      expect(attrs.name).to eq('my-app')
    end

    it 'raises on missing name' do
      expect { described_class.new({}) }.to raise_error(Dry::Struct::Error)
    end

    it 'accepts all optional attributes' do
      attrs = described_class.new(
        name: 'full-app',
        auth: 'admin:password',
        explicit_appname: 'my_explicit_app',
        label: 'My App',
        filename: true,
        update: false,
        visible: true
      )
      expect(attrs.auth).to eq('admin:password')
      expect(attrs.explicit_appname).to eq('my_explicit_app')
      expect(attrs.label).to eq('My App')
      expect(attrs.filename).to eq(true)
      expect(attrs.update).to eq(false)
      expect(attrs.visible).to eq(true)
    end

    it 'defaults optional attributes to nil' do
      attrs = described_class.new(name: 'minimal')
      expect(attrs.auth).to be_nil
      expect(attrs.explicit_appname).to be_nil
      expect(attrs.filename).to be_nil
      expect(attrs.update).to be_nil
      expect(attrs.visible).to be_nil
    end

    it 'accepts string keys via transform_keys' do
      attrs = described_class.new('name' => 'string-app', 'label' => 'String App')
      expect(attrs.name).to eq('string-app')
      expect(attrs.label).to eq('String App')
    end
  end
end
