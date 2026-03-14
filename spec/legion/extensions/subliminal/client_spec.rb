# frozen_string_literal: true

RSpec.describe Legion::Extensions::Subliminal::Client do
  subject(:client) { described_class.new }

  it 'responds to runner methods' do
    expect(client).to respond_to(:create_subliminal_trace, :process_influences, :subliminal_status)
  end

  it 'runs a full subliminal lifecycle' do
    result = client.create_subliminal_trace(content: 'danger signal', domain: :security)
    trace_id = result[:trace][:id]

    client.boost_trace(trace_id: trace_id)
    client.process_influences
    client.decay_all

    status = client.subliminal_status
    expect(status[:total_traces]).to be >= 1
  end
end
