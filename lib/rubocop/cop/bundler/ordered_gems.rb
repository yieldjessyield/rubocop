# frozen_string_literal: true

module RuboCop
  module Cop
    module Bundler
      # Gems should be alphabetically sorted within groups.
      #
      # @example
      #   # bad
      #   gem 'rubocop'
      #   gem 'rspec'
      #
      #   # good
      #   gem 'rspec'
      #   gem 'rubocop'
      #
      #   # good
      #   gem 'rubocop'
      #
      #   gem 'rspec'
      #
      #   # good only if TreatCommentsAsGroupSeparators is true
      #   # For code quality
      #   gem 'rubocop'
      #   # For tests
      #   gem 'rspec'
      class OrderedGems < Cop
        include ConfigurableEnforcedStyle
        include OrderedGemNode

        MSG = 'Gems should be sorted in an alphabetical order within their '\
              'section of the Gemfile. '\
              'Gem `%s` should appear before `%s`.'.freeze

        def investigate(processed_source)
          return if processed_source.ast.nil?
          gem_declarations(processed_source.ast)
            .each_cons(2) do |previous, current|
            next unless consecutive_lines(previous, current)
            next unless case_insensitive_out_of_order?(
              gem_name(current),
              gem_name(previous)
            )
            register_offense(previous, current)
          end
        end

        private

        def previous_declaration(node)
          declarations = gem_declarations(processed_source.ast)
          node_index = declarations.find_index(node)
          declarations.to_a[node_index - 1]
        end

        def_node_search :gem_declarations, <<-PATTERN
          (:send nil? :gem ...)
        PATTERN
      end
    end
  end
end
