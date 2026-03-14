# frozen_string_literal: true

RSpec.describe Legion::Extensions::Subliminal::Helpers::SubliminalEngine do
  subject(:engine) { described_class.new }

  describe '#create_trace' do
    it 'creates and stores a trace' do
      trace = engine.create_trace(content: 'faint memory')
      expect(trace.content).to eq('faint memory')
    end
  end

  describe '#boost_trace' do
    it 'boosts activation' do
      trace = engine.create_trace(content: 'test')
      original = trace.activation
      engine.boost_trace(trace_id: trace.id)
      expect(trace.activation).to be > original
    end

    it 'returns nil for unknown trace' do
      expect(engine.boost_trace(trace_id: 'bad')).to be_nil
    end
  end

  describe '#process_influences!' do
    it 'generates influence events from active traces' do
      engine.create_trace(content: 'a', activation: 0.3)
      result = engine.process_influences!
      expect(result[:influences_generated]).to be >= 1
    end

    it 'returns empty when no active traces' do
      result = engine.process_influences!
      expect(result[:influences_generated]).to eq(0)
    end
  end

  describe '#decay_all!' do
    it 'decays all traces' do
      trace = engine.create_trace(content: 'test')
      original = trace.activation
      engine.decay_all!
      expect(trace.activation).to be < original
    end
  end

  describe '#active_traces' do
    it 'returns non-extinct traces' do
      engine.create_trace(content: 'active', activation: 0.2)
      expect(engine.active_traces.size).to eq(1)
    end
  end

  describe '#near_threshold_traces' do
    it 'returns traces near conscious threshold' do
      engine.create_trace(content: 'near', activation: 0.35)
      engine.create_trace(content: 'far', activation: 0.1)
      expect(engine.near_threshold_traces.size).to eq(1)
    end
  end

  describe '#potent_traces' do
    it 'returns traces with activation >= 0.2' do
      engine.create_trace(content: 'potent', activation: 0.25)
      engine.create_trace(content: 'weak', activation: 0.05)
      expect(engine.potent_traces.size).to eq(1)
    end
  end

  describe '#traces_by_domain' do
    it 'filters by domain' do
      engine.create_trace(content: 'a', domain: :security)
      engine.create_trace(content: 'b', domain: :memory)
      expect(engine.traces_by_domain(domain: :security).size).to eq(1)
    end
  end

  describe '#traces_by_type' do
    it 'filters by trace type' do
      engine.create_trace(content: 'a', trace_type: :emotional)
      engine.create_trace(content: 'b', trace_type: :procedural)
      expect(engine.traces_by_type(trace_type: :emotional).size).to eq(1)
    end
  end

  describe '#traces_by_target' do
    it 'filters by influence target' do
      engine.create_trace(content: 'a', influence_target: :emotion)
      engine.create_trace(content: 'b', influence_target: :decision)
      expect(engine.traces_by_target(target: :emotion).size).to eq(1)
    end
  end

  describe '#influence_on' do
    it 'returns 0.0 with no influences' do
      expect(engine.influence_on(target: :attention)).to eq(0.0)
    end

    it 'returns accumulated influence after processing' do
      engine.create_trace(content: 'a', activation: 0.3, influence_target: :attention)
      engine.process_influences!
      expect(engine.influence_on(target: :attention)).to be > 0.0
    end
  end

  describe '#domain_saturation' do
    it 'returns 0.0 for empty domain' do
      expect(engine.domain_saturation(domain: :security)).to eq(0.0)
    end

    it 'returns positive for populated domain' do
      engine.create_trace(content: 'a', domain: :security, activation: 0.3)
      expect(engine.domain_saturation(domain: :security)).to be > 0.0
    end
  end

  describe '#overall_subliminal_load' do
    it 'returns 0.0 with no traces' do
      expect(engine.overall_subliminal_load).to eq(0.0)
    end

    it 'returns positive with active traces' do
      engine.create_trace(content: 'a', activation: 0.3)
      expect(engine.overall_subliminal_load).to be > 0.0
    end
  end

  describe '#strongest_traces' do
    it 'returns sorted by activation descending' do
      engine.create_trace(content: 'weak', activation: 0.1)
      strong = engine.create_trace(content: 'strong', activation: 0.35)
      expect(engine.strongest_traces(limit: 1).first.id).to eq(strong.id)
    end
  end

  describe '#breached_traces' do
    it 'returns empty when all below threshold' do
      engine.create_trace(content: 'below', activation: 0.3)
      expect(engine.breached_traces).to be_empty
    end
  end

  describe '#subliminal_report' do
    it 'includes all report fields' do
      report = engine.subliminal_report
      expect(report).to include(
        :total_traces, :active_count, :near_threshold, :potent_count,
        :total_influences, :subliminal_load, :saturation_label,
        :breached_count, :strongest
      )
    end
  end

  describe '#to_h' do
    it 'includes summary fields' do
      hash = engine.to_h
      expect(hash).to include(:total_traces, :active, :subliminal_load, :total_influences)
    end
  end
end
