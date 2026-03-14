# frozen_string_literal: true

RSpec.describe Legion::Extensions::Subliminal::Helpers::SubliminalTrace do
  subject(:trace) { described_class.new(content: 'faint memory of danger') }

  describe '#initialize' do
    it 'assigns a UUID id' do
      expect(trace.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'stores content' do
      expect(trace.content).to eq('faint memory of danger')
    end

    it 'defaults trace_type to :associative' do
      expect(trace.trace_type).to eq(:associative)
    end

    it 'defaults domain to :general' do
      expect(trace.domain).to eq(:general)
    end

    it 'defaults activation to DEFAULT_ACTIVATION' do
      expect(trace.activation).to eq(0.2)
    end

    it 'clamps activation to subliminal ceiling' do
      high = described_class.new(content: 'x', activation: 0.9)
      expect(high.activation).to eq(0.39)
    end

    it 'clamps activation to subliminal floor' do
      low = described_class.new(content: 'x', activation: 0.001)
      expect(low.activation).to eq(0.02)
    end

    it 'defaults influence_target to :attention' do
      expect(trace.influence_target).to eq(:attention)
    end

    it 'validates trace_type' do
      bad = described_class.new(content: 'x', trace_type: :nonexistent)
      expect(bad.trace_type).to eq(:associative)
    end

    it 'validates influence_target' do
      bad = described_class.new(content: 'x', influence_target: :nonexistent)
      expect(bad.influence_target).to eq(:attention)
    end
  end

  describe '#boost!' do
    it 'increases activation' do
      original = trace.activation
      trace.boost!
      expect(trace.activation).to be > original
    end

    it 'clamps at subliminal ceiling' do
      10.times { trace.boost! }
      expect(trace.activation).to eq(0.39)
    end
  end

  describe '#decay!' do
    it 'decreases activation' do
      original = trace.activation
      trace.decay!
      expect(trace.activation).to be < original
    end

    it 'clamps at 0.0' do
      50.times { trace.decay! }
      expect(trace.activation).to eq(0.0)
    end
  end

  describe '#exert_influence!' do
    it 'returns influence magnitude' do
      mag = trace.exert_influence!
      expect(mag).to be > 0.0
    end

    it 'increments influence_count' do
      trace.exert_influence!
      expect(trace.influence_count).to eq(1)
    end

    it 'slightly decreases activation' do
      original = trace.activation
      trace.exert_influence!
      expect(trace.activation).to be < original
    end
  end

  describe '#near_threshold?' do
    it 'is false at default activation' do
      expect(trace.near_threshold?).to be false
    end

    it 'is true when near conscious threshold' do
      near = described_class.new(content: 'x', activation: 0.35)
      expect(near.near_threshold?).to be true
    end
  end

  describe '#active?' do
    it 'is true at default activation' do
      expect(trace.active?).to be true
    end

    it 'is false when fully decayed' do
      50.times { trace.decay! }
      expect(trace.active?).to be false
    end
  end

  describe '#extinct?' do
    it 'is false at default activation' do
      expect(trace.extinct?).to be false
    end

    it 'is true when nearly zero' do
      50.times { trace.decay! }
      expect(trace.extinct?).to be true
    end
  end

  describe '#potent?' do
    it 'is true at default activation' do
      expect(trace.potent?).to be true
    end

    it 'is false when low' do
      faint = described_class.new(content: 'x', activation: 0.1)
      expect(faint.potent?).to be false
    end
  end

  describe '#breached_threshold?' do
    it 'is false by default' do
      expect(trace.breached_threshold?).to be false
    end
  end

  describe '#persistence' do
    it 'is 1.0 initially' do
      expect(trace.persistence).to eq(1.0)
    end

    it 'decreases after decay' do
      trace.decay!
      expect(trace.persistence).to be < 1.0
    end
  end

  describe '#to_h' do
    it 'includes all fields' do
      hash = trace.to_h
      expect(hash).to include(
        :id, :content, :trace_type, :domain, :activation,
        :original_activation, :influence_target, :influence_count,
        :influence_magnitude, :near_threshold, :active, :extinct,
        :activation_label, :persistence, :created_at
      )
    end
  end
end
