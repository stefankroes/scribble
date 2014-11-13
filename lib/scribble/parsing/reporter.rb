module Scribble
  module Parsing
    class Reporter
      Cause = Struct.new :source, :position do
        def strings
          @strings ||= []
        end

        def raise
          Kernel.raise Errors::Syntax.new "#{unexpected} at line #{line} column #{column}#{explanation}"
        end

        def unexpected
          if character
            "Unexpected '#{character}'"
          else
            "Unexpected end of template"
          end
        end

        def character
          source.instance_variable_get(:@str).string[position]
        end

        def line
          source.line_and_column(position).first
        end

        def column
          source.line_and_column(position).last
        end

        def explanation
          if unterminated_string?
            "; unterminated string"
          else
            ", expected #{Support::Utilities.to_sentence expected}"
          end
        end

        def unterminated_string?
          strings.all? { |string| ["\\", "'"].include? string }
        end

        def expected
          strings.map do |string|
            if    string == 'true' then "a value"
            elsif string == '+'    then "an operator"
            elsif string == '('    then "'('"
            elsif string == '}}'   then "'}}'"
            elsif string == 'end'  then "'end'"
            end
          end.compact.uniq.sort
        end
      end

      def err atom, source, message, children = nil
        err_at atom, source, message, source.pos, children
      end

      def err_at atom, source, message, position, children = nil
        if @position.nil? || position > @position
          @position = position
          @cause = Cause.new source, position
        end
        @cause.strings << atom.str if position == @position && atom.respond_to?(:str)
        @cause
      end
    end
  end
end
