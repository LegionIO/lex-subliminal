# frozen_string_literal: true

module Legion
  module Extensions
    module Subliminal
      module Runners
        module Subliminal
          include Legion::Extensions::Helpers::Lex if defined?(Legion::Extensions::Helpers::Lex)

          def create_subliminal_trace(content:, trace_type: :associative, domain: :general, activation: nil, influence_target: :attention, engine: nil, **)
            eng = engine || @default_engine
            trace = eng.create_trace(content: content, trace_type: trace_type, domain: domain,
                                     activation: activation || Helpers::Constants::DEFAULT_ACTIVATION,
                                     influence_target: influence_target)
            { success: true, trace: trace.to_h }
          end

          def boost_trace(trace_id:, amount: nil, engine: nil, **)
            eng = engine || @default_engine
            trace = eng.boost_trace(trace_id: trace_id, amount: amount || Helpers::Constants::ACTIVATION_BOOST)
            return { success: false, error: 'trace not found' } unless trace

            { success: true, trace: trace.to_h }
          end

          def process_influences(engine: nil, **)
            eng = engine || @default_engine
            result = eng.process_influences!
            { success: true, **result }
          end

          def decay_all(engine: nil, **)
            eng = engine || @default_engine
            result = eng.decay_all!
            { success: true, **result }
          end

          def active_traces(engine: nil, **)
            eng = engine || @default_engine
            traces = eng.active_traces
            { success: true, count: traces.size, traces: traces.map(&:to_h) }
          end

          def near_threshold(engine: nil, **)
            eng = engine || @default_engine
            traces = eng.near_threshold_traces
            { success: true, count: traces.size, traces: traces.map(&:to_h) }
          end

          def influence_on(target:, engine: nil, **)
            eng = engine || @default_engine
            level = eng.influence_on(target: target)
            label = Helpers::Constants.label_for(Helpers::Constants::INFLUENCE_LABELS, level)
            { success: true, target: target, influence: level, label: label }
          end

          def subliminal_status(engine: nil, **)
            eng = engine || @default_engine
            report = eng.subliminal_report
            { success: true, **report }
          end
        end
      end
    end
  end
end
