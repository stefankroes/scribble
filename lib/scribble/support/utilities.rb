module Scribble
  module Support
    class Utilities
      class << self

        # String repetition

        def repeat string, count
          raise Errors::UnlocatedArgument.new("Can't repeat string a negative number of times") if count < 0
          string * count
        end

        # String truncation

        def truncate string, on_words, length, omission
          raise Errors::UnlocatedArgument.new("Can't truncate string with a negative length") if length < 0

          truncated = if on_words
            string[/(\s*\S*){#{length}}/]
          else
            string[0, length]
          end

          if string != truncated then truncated + omission else string end
        end

        # Array to sentence

        def to_sentence strings, final_separator = ' or '
          [strings[0..-2].join(', '), strings[-1].to_s].reject(&:empty?).join(final_separator)
        end

        # Ordinalize number
        def ordinalize number
          if (11..13).include?(number % 100)
            "#{number}th"
          else
            case number % 10
            when 1; "#{number}st"
            when 2; "#{number}nd"
            when 3; "#{number}rd"
            else    "#{number}th"
            end
          end
        end
      end
    end
  end
end
