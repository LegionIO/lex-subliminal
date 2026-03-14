# frozen_string_literal: true

module Legion
  module Extensions
    module Subliminal
      class Client
        include Runners::Subliminal

        def initialize
          @default_engine = Helpers::SubliminalEngine.new
        end
      end
    end
  end
end
