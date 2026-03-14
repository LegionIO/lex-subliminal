# lex-subliminal

**Level 3 Leaf Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Gem**: `lex-subliminal`
- **Version**: `0.1.0`
- **Namespace**: `Legion::Extensions::Subliminal`

## Purpose

Models subliminal (below-threshold) influences on cognition. Subliminal traces carry an activation level that is structurally prevented from reaching the conscious threshold — they cannot be consciously attended to, but they exert a measurable influence on named cognitive targets (attention, memory, decision, emotion, etc.). Traces decay over time; those that fall to near-zero are extinct. Useful for modeling background priming, emotional contagion, implicit learning, and attentional drift.

## Gem Info

- **Gem name**: `lex-subliminal`
- **License**: MIT
- **Ruby**: >= 3.4
- **No runtime dependencies** beyond the Legion framework

## File Structure

```
lib/legion/extensions/subliminal/
  version.rb                        # VERSION = '0.1.0'
  helpers/
    constants.rb                    # thresholds, decay rates, influence strength, max caps, type/target lists, labels
    subliminal_trace.rb             # SubliminalTrace class — single below-threshold activation trace
    subliminal_engine.rb            # SubliminalEngine class — collection with bulk influence processing
  runners/
    subliminal.rb                   # Runners::Subliminal module — all public runner methods
  client.rb                         # Client class including Runners::Subliminal
```

## Key Constants

| Constant | Value | Purpose |
|---|---|---|
| `CONSCIOUS_THRESHOLD` | 0.4 | The threshold subliminal traces are prevented from reaching |
| `SUBLIMINAL_CEILING` | 0.39 | Hard cap on trace activation (just below CONSCIOUS_THRESHOLD) |
| `SUBLIMINAL_FLOOR` | 0.02 | Minimum activation before approaching extinction |
| `EXTINCTION_THRESHOLD` | 0.01 | At or below this, trace is considered extinct |
| `DEFAULT_ACTIVATION` | 0.2 | Starting activation for new traces |
| `ACTIVATION_BOOST` | 0.08 | Activation increase per `boost!` call |
| `ACTIVATION_DECAY` | 0.015 | Per-tick activation decrease |
| `INFLUENCE_STRENGTH` | 0.05 | Magnitude multiplier: `activation * INFLUENCE_STRENGTH` |
| `MAX_INFLUENCE_PER_DOMAIN` | 0.3 | Maximum total influence on any single domain |
| `MAX_TOTAL_INFLUENCE` | 0.5 | Maximum combined influence across all targets |
| `TRACE_TYPES` | 8 symbols | `:priming`, `:emotional`, `:procedural`, `:semantic`, `:inhibitory`, `:motivational`, `:contextual`, `:evaluative` |
| `INFLUENCE_TARGETS` | 8 symbols | `:attention`, `:memory`, `:decision`, `:emotion`, `:action`, `:perception`, `:language`, `:reasoning` |

## Helpers

### `Helpers::SubliminalTrace`

Single below-threshold activation trace.

- `initialize(id:, content:, trace_type:, domain: :general, target: :attention, activation: DEFAULT_ACTIVATION)` — clamps activation to SUBLIMINAL_CEILING on init
- `boost!(amount = ACTIVATION_BOOST)` — increments activation; hard-clamps to SUBLIMINAL_CEILING (never reaches CONSCIOUS_THRESHOLD)
- `decay!` — decrements activation by ACTIVATION_DECAY; floors at 0.0
- `exert_influence!` — decrements activation slightly, returns `influence_magnitude`
- `influence_magnitude` — `activation * INFLUENCE_STRENGTH`
- `near_threshold?` — activation between 0.3 and 0.39
- `active?` — activation > EXTINCTION_THRESHOLD
- `extinct?` — activation <= EXTINCTION_THRESHOLD
- `potent?` — activation >= 0.2
- `breached_threshold?` — activation >= 0.4 (anomaly: should never occur due to ceiling, logged if detected)
- `activation_label` — `:extinct`, `:faint`, `:weak`, `:moderate`, `:strong` based on activation

### `Helpers::SubliminalEngine`

Collection of SubliminalTrace objects with bulk influence processing.

- `initialize` — traces hash, keyed by trace id
- `create_trace(content:, trace_type:, domain: :general, target: :attention, activation: DEFAULT_ACTIVATION)` — rejects invalid types/targets; appends trace
- `boost_trace(trace_id, amount: ACTIVATION_BOOST)` — calls `trace.boost!`
- `process_influences!` — all active traces call `exert_influence!`; generates InfluenceEvent objects per trace; returns events array
- `decay_all!` — decays all traces; removes extinct ones
- `active_traces` — all with `active? == true`
- `near_threshold_traces` — all with `near_threshold? == true`
- `potent_traces` — all with `potent? == true`
- `traces_by_domain(domain)` — filter by domain
- `traces_by_type(trace_type)` — filter by trace_type
- `traces_by_target(target)` — filter by influence target
- `influence_on(target:)` — sum of influence_magnitude across all active traces targeting `target`; capped at MAX_INFLUENCE_PER_DOMAIN
- `domain_saturation(domain)` — total influence magnitude across all traces in domain
- `overall_subliminal_load` — sum of all active trace activations; capped at MAX_TOTAL_INFLUENCE
- `strongest_traces(limit: 5)` — sorted by activation descending
- `breached_traces` — any traces with `breached_threshold? == true` (anomaly detection)
- `subliminal_report` — summary: trace counts, overall load, influence per target, near-threshold count

## Runners

All runners are in `Runners::Subliminal`. The `Client` includes this module. Note: the runner uses `@default_engine` internally (not `@engine`).

| Runner | Parameters | Returns |
|---|---|---|
| `create_subliminal_trace` | `content:, trace_type:, domain: :general, target: :attention, activation: DEFAULT_ACTIVATION` | `{ success:, trace_id:, activation:, trace_type: }` |
| `boost_trace` | `trace_id:, amount: ACTIVATION_BOOST` | `{ success:, trace_id:, activation: }` |
| `process_influences` | (none) | `{ success:, events:, count: }` — runs `process_influences!` |
| `decay_all` | (none) | `{ success:, active_count:, removed_count: }` |
| `active_traces` | (none) | `{ success:, traces:, count: }` |
| `near_threshold` | (none) | `{ success:, traces:, count: }` — traces approaching conscious threshold |
| `influence_on` | `target:` | `{ success:, target:, influence: }` |
| `subliminal_status` | (none) | Full `SubliminalEngine#subliminal_report` hash |

## Integration Points

- **lex-tick / lex-cortex**: `process_influences` wired as a tick phase handler to apply subliminal influence each cycle; influence events can be forwarded to target extensions (e.g., influence on `:attention` biases the sensory gating thresholds)
- **lex-sensory-gating**: subliminal influence on `:perception` can modulate gate thresholds without the agent's explicit awareness
- **lex-emotion**: `:emotional` trace type targeting `:emotion` models emotional contagion and implicit mood induction
- **lex-dream**: dream consolidation may create subliminal traces from unresolved material; `:contextual` traces targeting `:decision` model incubation effects
- **lex-semantic-priming**: near-threshold traces can trigger priming events when their target aligns with active concept nodes

## Development Notes

- `SUBLIMINAL_CEILING = 0.39` is a hard cap enforced in both `initialize` and `boost!` — traces structurally cannot reach CONSCIOUS_THRESHOLD, making the subliminal/conscious boundary a guaranteed architectural constraint
- `breached_threshold?` >= 0.4 should never trigger in normal operation; it is an anomaly detection flag
- `process_influences!` slightly decrements activation on each call — sustained influence gradually weakens the trace
- `@default_engine` naming (vs `@engine`) is specific to this runner module; specs and injection must reference `@default_engine`
- InfluenceEvent objects from `process_influences!` are plain structs (trace_id, target, magnitude, domain) — callers can route them to downstream handlers by target
