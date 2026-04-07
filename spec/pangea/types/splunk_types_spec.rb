# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Pangea::Resources::Splunk::Types' do
  let(:types) { Pangea::Resources::Splunk::Types }

  # ── IndexDatatype constraint ────────────────────────────────────────
  # Catches: accepting invalid datatype values that Splunk would reject

  describe 'IndexDatatype' do
    it 'accepts "event"' do
      expect(types::IndexDatatype['event']).to eq('event')
    end

    it 'accepts "metric"' do
      expect(types::IndexDatatype['metric']).to eq('metric')
    end

    it 'rejects invalid datatype values' do
      expect { types::IndexDatatype['invalid'] }.to raise_error(Dry::Types::ConstraintError)
    end

    it 'rejects empty string' do
      expect { types::IndexDatatype[''] }.to raise_error(Dry::Types::ConstraintError)
    end

    it 'rejects nil' do
      expect { types::IndexDatatype[nil] }.to raise_error(Dry::Types::CoercionError)
    end
  end

  # ── AlertType constraint ────────────────────────────────────────────
  # Catches: typos or invalid alert type strings silently passing through

  describe 'AlertType' do
    %w[always custom].each do |valid_type|
      it "accepts '#{valid_type}'" do
        expect(types::AlertType[valid_type]).to eq(valid_type)
      end
    end

    ['number of events', 'number of hosts', 'number of sources'].each do |valid_type|
      it "accepts '#{valid_type}'" do
        expect(types::AlertType[valid_type]).to eq(valid_type)
      end
    end

    it 'rejects invalid alert type' do
      expect { types::AlertType['invalid_type'] }.to raise_error(Dry::Types::ConstraintError)
    end

    it 'rejects case-variant of valid type' do
      expect { types::AlertType['Always'] }.to raise_error(Dry::Types::ConstraintError)
    end
  end

  # ── AlertComparator constraint ──────────────────────────────────────
  # Catches: invalid comparator strings that would cause Splunk API errors

  describe 'AlertComparator' do
    [
      'greater than', 'less than', 'equal to',
      'rises by', 'drops by', 'rises by perc', 'drops by perc'
    ].each do |valid_comp|
      it "accepts '#{valid_comp}'" do
        expect(types::AlertComparator[valid_comp]).to eq(valid_comp)
      end
    end

    it 'rejects invalid comparator' do
      expect { types::AlertComparator['not equal'] }.to raise_error(Dry::Types::ConstraintError)
    end

    it 'rejects empty string' do
      expect { types::AlertComparator[''] }.to raise_error(Dry::Types::ConstraintError)
    end
  end
end
