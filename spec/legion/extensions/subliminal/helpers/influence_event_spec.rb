# frozen_string_literal: true

RSpec.describe Legion::Extensions::Subliminal::Helpers::InfluenceEvent do
  subject(:event) do
    described_class.new(trace_id: 'abc-123', target: :attention, magnitude: 0.08, domain: :security)
  end

  describe '#initialize' do
    it 'assigns a UUID id' do
      expect(event.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'stores trace_id' do
      expect(event.trace_id).to eq('abc-123')
    end

    it 'stores target' do
      expect(event.target).to eq(:attention)
    end

    it 'stores magnitude' do
      expect(event.magnitude).to eq(0.08)
    end

    it 'stores domain' do
      expect(event.domain).to eq(:security)
    end
  end

  describe '#significant?' do
    it 'is true for magnitude >= 0.05' do
      expect(event.significant?).to be true
    end

    it 'is false for small magnitude' do
      small = described_class.new(trace_id: 'x', target: :emotion, magnitude: 0.03)
      expect(small.significant?).to be false
    end
  end

  describe '#subtle?' do
    it 'is true for small positive magnitude' do
      small = described_class.new(trace_id: 'x', target: :emotion, magnitude: 0.03)
      expect(small.subtle?).to be true
    end

    it 'is false for significant magnitude' do
      expect(event.subtle?).to be false
    end
  end

  describe '#to_h' do
    it 'includes all fields' do
      hash = event.to_h
      expect(hash).to include(:id, :trace_id, :target, :magnitude, :domain, :created_at)
    end
  end
end
