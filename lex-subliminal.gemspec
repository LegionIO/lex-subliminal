# frozen_string_literal: true

require_relative 'lib/legion/extensions/subliminal/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-subliminal'
  spec.version       = Legion::Extensions::Subliminal::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']
  spec.summary       = 'Subliminal activation and below-threshold influence for LegionIO agents'
  spec.description   = 'Models below-threshold cognitive traces that influence behavior ' \
                       'without reaching conscious awareness in the LegionIO architecture'
  spec.homepage      = 'https://github.com/LegionIO/lex-subliminal'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata = {
    'homepage_uri'          => spec.homepage,
    'source_code_uri'       => spec.homepage,
    'documentation_uri'     => "#{spec.homepage}/blob/origin/README.md",
    'changelog_uri'         => "#{spec.homepage}/blob/origin/CHANGELOG.md",
    'bug_tracker_uri'       => "#{spec.homepage}/issues",
    'rubygems_mfa_required' => 'true'
  }

  spec.files = Dir.chdir(__dir__) { `git ls-files -z`.split("\x0") }
  spec.require_paths = ['lib']
end
