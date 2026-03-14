# frozen_string_literal: true

module Legion
  module Extensions
    module Subliminal
      module Helpers
        module Constants
          MAX_TRACES = 500
          MAX_INFLUENCES = 1000

          # Threshold boundaries
          CONSCIOUS_THRESHOLD = 0.4
          SUBLIMINAL_CEILING = 0.39
          SUBLIMINAL_FLOOR = 0.02
          EXTINCTION_THRESHOLD = 0.01

          # Dynamics
          DEFAULT_ACTIVATION = 0.2
          ACTIVATION_BOOST = 0.08
          ACTIVATION_DECAY = 0.015
          INFLUENCE_STRENGTH = 0.05
          ACCUMULATION_RATE = 0.03

          # Influence caps
          MAX_INFLUENCE_PER_DOMAIN = 0.3
          MAX_TOTAL_INFLUENCE = 0.5

          TRACE_TYPES = %i[
            perceptual emotional associative procedural
            semantic motivational aversive appetitive
          ].freeze

          INFLUENCE_TARGETS = %i[
            attention emotion decision memory
            preference avoidance approach valence
          ].freeze

          ACTIVATION_LABELS = {
            (0.3...0.4)  => :near_threshold,
            (0.2...0.3)  => :moderate,
            (0.1...0.2)  => :faint,
            (0.02...0.1) => :trace,
            (..0.02)     => :extinct
          }.freeze

          INFLUENCE_LABELS = {
            (0.2..)       => :strong,
            (0.1...0.2)   => :moderate,
            (0.05...0.1)  => :subtle,
            (0.01...0.05) => :minimal,
            (..0.01)      => :none
          }.freeze

          SATURATION_LABELS = {
            (0.8..)     => :saturated,
            (0.6...0.8) => :heavy,
            (0.4...0.6) => :moderate,
            (0.2...0.4) => :light,
            (..0.2)     => :clear
          }.freeze

          def self.label_for(labels, value)
            labels.each { |range, label| return label if range.cover?(value) }
            :unknown
          end
        end
      end
    end
  end
end
