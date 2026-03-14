# lex-subliminal

Subliminal influence modeling for LegionIO cognitive agents. Traces operate below the conscious threshold but exert measurable influence on attention, memory, decision-making, and emotion.

## What It Does

`lex-subliminal` maintains a set of activation traces that are structurally capped below the conscious threshold (0.39 max, threshold at 0.4). These traces cannot be consciously attended to but exert influence on named cognitive targets each tick. Traces decay over time; those that reach near-zero are extinct.

- **Trace types**: `:priming`, `:emotional`, `:procedural`, `:semantic`, `:inhibitory`, `:motivational`, `:contextual`, `:evaluative`
- **Influence targets**: `:attention`, `:memory`, `:decision`, `:emotion`, `:action`, `:perception`, `:language`, `:reasoning`
- **Activation ceiling**: 0.39 — structurally enforced; traces can never breach conscious threshold
- **Influence magnitude**: `activation * 0.05` per trace per tick
- **Potent traces**: activation >= 0.2; near-threshold traces: activation 0.3–0.39

## Usage

```ruby
require 'legion/extensions/subliminal'

client = Legion::Extensions::Subliminal::Client.new

# Create a subliminal trace
result = client.create_subliminal_trace(
  content: 'unresolved conflict',
  trace_type: :emotional,
  domain: :relationships,
  target: :decision,
  activation: 0.25
)
trace_id = result[:trace_id]

# Boost a trace (activation can never exceed 0.39)
client.boost_trace(trace_id: trace_id, amount: 0.08)

# Process influences (called each tick)
client.process_influences
# => { events: [{ target: :decision, magnitude: 0.017, ... }], count: 1 }

# Check influence on a specific target
client.influence_on(target: :decision)
# => { target: :decision, influence: 0.017 }

# Near-threshold traces (approaching conscious awareness)
client.near_threshold
# => { traces: [...], count: 0 }

# Decay all traces
client.decay_all
# => { active_count: 1, removed_count: 0 }

# Full status report
client.subliminal_status
# => { trace_count:, active_count:, overall_load:, influence_per_target: { ... }, ... }
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
