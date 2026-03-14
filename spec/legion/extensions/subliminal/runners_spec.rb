# frozen_string_literal: true

RSpec.describe Legion::Extensions::Subliminal::Runners::Subliminal do
  let(:engine) { Legion::Extensions::Subliminal::Helpers::SubliminalEngine.new }
  let(:runner) do
    obj = Object.new
    obj.extend(described_class)
    obj.instance_variable_set(:@default_engine, engine)
    obj
  end

  describe '#create_subliminal_trace' do
    it 'returns success with trace hash' do
      result = runner.create_subliminal_trace(content: 'test', engine: engine)
      expect(result[:success]).to be true
      expect(result[:trace][:content]).to eq('test')
    end
  end

  describe '#boost_trace' do
    it 'returns success for known trace' do
      trace = engine.create_trace(content: 'test')
      result = runner.boost_trace(trace_id: trace.id, engine: engine)
      expect(result[:success]).to be true
    end

    it 'returns failure for unknown trace' do
      result = runner.boost_trace(trace_id: 'bad', engine: engine)
      expect(result[:success]).to be false
    end
  end

  describe '#process_influences' do
    it 'returns success' do
      result = runner.process_influences(engine: engine)
      expect(result[:success]).to be true
    end
  end

  describe '#decay_all' do
    it 'returns success' do
      result = runner.decay_all(engine: engine)
      expect(result[:success]).to be true
    end
  end

  describe '#active_traces' do
    it 'returns active list' do
      engine.create_trace(content: 'test')
      result = runner.active_traces(engine: engine)
      expect(result[:count]).to eq(1)
    end
  end

  describe '#near_threshold' do
    it 'returns near-threshold list' do
      engine.create_trace(content: 'near', activation: 0.35)
      result = runner.near_threshold(engine: engine)
      expect(result[:count]).to eq(1)
    end
  end

  describe '#influence_on' do
    it 'returns influence level' do
      result = runner.influence_on(target: :attention, engine: engine)
      expect(result[:success]).to be true
      expect(result[:influence]).to eq(0.0)
    end
  end

  describe '#subliminal_status' do
    it 'returns comprehensive status' do
      result = runner.subliminal_status(engine: engine)
      expect(result[:success]).to be true
      expect(result).to include(:total_traces, :subliminal_load)
    end
  end
end
