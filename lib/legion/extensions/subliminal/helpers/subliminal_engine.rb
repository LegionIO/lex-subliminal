# frozen_string_literal: true

module Legion
  module Extensions
    module Subliminal
      module Helpers
        class SubliminalEngine
          include Constants

          def initialize
            @traces = {}
            @influences = []
          end

          def create_trace(content:, trace_type: :associative, domain: :general, activation: DEFAULT_ACTIVATION,
                           influence_target: :attention)
            prune_extinct
            trace = SubliminalTrace.new(content: content, trace_type: trace_type, domain: domain,
                                        activation: activation, influence_target: influence_target)
            @traces[trace.id] = trace
            trace
          end

          def boost_trace(trace_id:, amount: ACTIVATION_BOOST)
            trace = @traces[trace_id]
            return nil unless trace

            trace.boost!(amount: amount)
            trace
          end

          def process_influences!
            active = active_traces
            events = []
            active.each do |trace|
              mag = trace.exert_influence!
              next if mag <= 0.0

              event = InfluenceEvent.new(trace_id: trace.id, target: trace.influence_target,
                                         magnitude: mag, domain: trace.domain)
              events << event
              @influences << event
            end
            prune_influences
            { influences_generated: events.size, events: events.map(&:to_h) }
          end

          def decay_all!
            @traces.each_value(&:decay!)
            prune_extinct
            { traces_remaining: @traces.size }
          end

          def active_traces = @traces.values.select(&:active?)
          def near_threshold_traces = @traces.values.select(&:near_threshold?)
          def potent_traces = @traces.values.select(&:potent?)
          def extinct_traces = @traces.values.select(&:extinct?)

          def traces_by_domain(domain:)
            @traces.values.select { |t| t.domain == domain.to_sym }
          end

          def traces_by_type(trace_type:)
            @traces.values.select { |t| t.trace_type == trace_type.to_sym }
          end

          def traces_by_target(target:)
            @traces.values.select { |t| t.influence_target == target.to_sym }
          end

          def influence_on(target:)
            recent = @influences.last(100).select { |e| e.target == target.to_sym }
            return 0.0 if recent.empty?

            recent.sum(&:magnitude).clamp(0.0, MAX_TOTAL_INFLUENCE).round(10)
          end

          def domain_saturation(domain:)
            domain_traces = traces_by_domain(domain: domain)
            return 0.0 if domain_traces.empty?

            total_activation = domain_traces.sum(&:activation)
            (total_activation / (domain_traces.size * SUBLIMINAL_CEILING)).clamp(0.0, 1.0).round(10)
          end

          def overall_subliminal_load
            return 0.0 if @traces.empty?

            active = active_traces
            return 0.0 if active.empty?

            (active.sum(&:activation) / (active.size * SUBLIMINAL_CEILING)).clamp(0.0, 1.0).round(10)
          end

          def saturation_label = Constants.label_for(SATURATION_LABELS, overall_subliminal_load)

          def strongest_traces(limit: 5) = @traces.values.sort_by { |t| -t.activation }.first(limit)

          def breached_traces
            @traces.values.select(&:breached_threshold?)
          end

          def subliminal_report
            {
              total_traces:     @traces.size,
              active_count:     active_traces.size,
              near_threshold:   near_threshold_traces.size,
              potent_count:     potent_traces.size,
              total_influences: @influences.size,
              subliminal_load:  overall_subliminal_load,
              saturation_label: saturation_label,
              breached_count:   breached_traces.size,
              strongest:        strongest_traces(limit: 3).map(&:to_h)
            }
          end

          def to_h
            {
              total_traces:     @traces.size,
              active:           active_traces.size,
              subliminal_load:  overall_subliminal_load,
              total_influences: @influences.size
            }
          end

          private

          def prune_extinct
            return if @traces.size < MAX_TRACES

            @traces.reject! { |_, t| t.extinct? }
            return unless @traces.size >= MAX_TRACES

            weakest = @traces.values.min_by(&:activation)
            @traces.delete(weakest.id) if weakest
          end

          def prune_influences
            @influences.shift while @influences.size > MAX_INFLUENCES
          end
        end
      end
    end
  end
end
