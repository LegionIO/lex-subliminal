# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module Subliminal
      module Helpers
        class SubliminalTrace
          include Constants

          attr_reader :id, :content, :trace_type, :domain, :original_activation,
                      :influence_target, :created_at, :influence_count
          attr_accessor :activation

          def initialize(content:, trace_type: :associative, domain: :general, activation: DEFAULT_ACTIVATION, influence_target: :attention)
            @id = SecureRandom.uuid
            @content = content.to_s
            @trace_type = valid_trace_type(trace_type)
            @domain = domain.to_sym
            @activation = activation.to_f.clamp(SUBLIMINAL_FLOOR, SUBLIMINAL_CEILING).round(10)
            @original_activation = @activation
            @influence_target = valid_influence_target(influence_target)
            @influence_count = 0
            @created_at = Time.now
          end

          def boost!(amount: ACTIVATION_BOOST)
            @activation = (@activation + amount).clamp(0.0, SUBLIMINAL_CEILING).round(10)
            self
          end

          def decay!
            @activation = (@activation - ACTIVATION_DECAY).clamp(0.0, 1.0).round(10)
            self
          end

          def exert_influence!
            @influence_count += 1
            @activation = (@activation - (INFLUENCE_STRENGTH * 0.5)).clamp(0.0, 1.0).round(10)
            influence_magnitude
          end

          def influence_magnitude
            (@activation * INFLUENCE_STRENGTH).clamp(0.0, MAX_INFLUENCE_PER_DOMAIN).round(10)
          end

          def near_threshold? = @activation >= 0.3 && @activation < CONSCIOUS_THRESHOLD
          def active? = @activation >= SUBLIMINAL_FLOOR
          def extinct? = @activation < EXTINCTION_THRESHOLD
          def potent? = @activation >= 0.2

          def breached_threshold?
            @activation >= CONSCIOUS_THRESHOLD
          end

          def persistence = (@activation / @original_activation).clamp(0.0, 1.0).round(10)
          def activation_label = Constants.label_for(ACTIVATION_LABELS, @activation)
          def influence_label = Constants.label_for(INFLUENCE_LABELS, influence_magnitude)

          def to_h
            {
              id:                  @id,
              content:             @content,
              trace_type:          @trace_type,
              domain:              @domain,
              activation:          @activation,
              original_activation: @original_activation,
              influence_target:    @influence_target,
              influence_count:     @influence_count,
              influence_magnitude: influence_magnitude,
              near_threshold:      near_threshold?,
              active:              active?,
              extinct:             extinct?,
              activation_label:    activation_label,
              persistence:         persistence,
              created_at:          @created_at.iso8601
            }
          end

          private

          def valid_trace_type(type)
            sym = type.to_sym
            TRACE_TYPES.include?(sym) ? sym : :associative
          end

          def valid_influence_target(target)
            sym = target.to_sym
            INFLUENCE_TARGETS.include?(sym) ? sym : :attention
          end
        end
      end
    end
  end
end
