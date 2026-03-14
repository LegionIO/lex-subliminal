# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module Subliminal
      module Helpers
        class InfluenceEvent
          include Constants

          attr_reader :id, :trace_id, :target, :magnitude, :domain, :created_at

          def initialize(trace_id:, target:, magnitude:, domain: :general)
            @id = SecureRandom.uuid
            @trace_id = trace_id
            @target = target.to_sym
            @magnitude = magnitude.to_f.clamp(0.0, MAX_INFLUENCE_PER_DOMAIN).round(10)
            @domain = domain.to_sym
            @created_at = Time.now
          end

          def significant? = @magnitude >= 0.05
          def subtle? = @magnitude < 0.05 && @magnitude > 0.0

          def to_h
            {
              id:         @id,
              trace_id:   @trace_id,
              target:     @target,
              magnitude:  @magnitude,
              domain:     @domain,
              created_at: @created_at.iso8601
            }
          end
        end
      end
    end
  end
end
