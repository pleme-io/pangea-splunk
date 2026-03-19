# frozen_string_literal: true

require 'dry-types'
require 'pangea/resources/types'

module Pangea
  module Resources
    module Splunk
      # Provider-specific Dry::Types for Splunk resources.
      # Individual resource types.rb files define Dry::Struct classes that
      # reference these via T = Pangea::Resources::Splunk::Types.
      module Types
        include Dry.Types()

        T = ::Pangea::Resources::Types

        # Index data types
        IndexDatatype = T::String.constrained(
          included_in: %w[event metric]
        )

        # Alert types for saved searches
        AlertType = T::String.constrained(
          included_in: [
            "number of events", "number of hosts", "number of sources",
            "custom", "always"
          ]
        )

        # Alert comparators for saved searches
        AlertComparator = T::String.constrained(
          included_in: [
            "greater than", "less than", "equal to",
            "rises by", "drops by", "rises by perc", "drops by perc"
          ]
        )
      end
    end
  end
end
