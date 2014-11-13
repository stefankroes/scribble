module Scribble
  module Support
    class Unmatched < Exception
      def initialize base_matches, expected, unexpected, max_cursor
        @base_matches, @expected, @unexpected, @max_cursor =
          base_matches, expected, unexpected, max_cursor
      end

      # Error message helpers

      def human_arities
        @base_matches.map do |method|
          [method.min_arity, method.max_arity]
        end.uniq.map do |min, max|
          max ? (min == max ? min.to_s : "#{min}-#{max}") : "#{min}+"
        end
      end

      def arg_to call
        "#{Support::Utilities.ordinalize @max_cursor + 1} argument to '#{call.name}'"
      end

      def expected_sentence
        "Expected #{Support::Utilities.to_sentence @expected}"
      end

      def unexpected_sentence call
        "got #{@unexpected} #{call.args[@max_cursor].line_and_column}"
      end

      # To error

      def to_error call
        if @base_matches.empty?
          Errors::Undefined.new "Undefined #{'variable or ' if call.allow_variable}"\
            "method '#{call.name}' #{call.line_and_column}"
        elsif @expected.empty? && @unexpected.nil?
          Errors::Arity.new "Wrong number of arguments (#{call.args.size} "\
            "for #{Support::Utilities.to_sentence human_arities}) "\
            "for '#{call.name}' #{call.line_and_column}"
        elsif @expected.empty?
          Errors::Argument.new "Unexpected #{arg_to call}, #{unexpected_sentence call}"
        elsif @unexpected.nil?
          Errors::Argument.new "#{expected_sentence} as #{arg_to call} #{call.line_and_column}"
        else
          Errors::Argument.new "#{expected_sentence} as #{arg_to call}, #{unexpected_sentence call}"
        end
      end

      # Merge unmatched exceptions to generate merged error

      attr_reader :base_matches, :expected, :unexpected, :max_cursor

      def merge unmatched
        @base_matches += unmatched.base_matches

        unless @max_cursor.nil?
          if unmatched.max_cursor > @max_cursor
            @max_cursor = unmatched.max_cursor
            @expected   = unmatched.expected
            @unexpected = unmatched.unexpected
          elsif unmatched.max_cursor == @max_cursor
            @expected   += unmatched.expected
          end
        end
        self
      end
    end
  end
end
