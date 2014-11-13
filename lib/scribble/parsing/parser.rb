require 'parslet'

module Scribble
  module Parsing
    class DelimitedChunk < Parslet::Atoms::Base
      def initialize delimiters, min_chars = 0
        @delimiters = delimiters
        @min_chars = min_chars
      end

      def try(source, context, consume_all)
        excluding_length = @delimiters.map {|d| source.chars_until(d) }.min

        if excluding_length >= @min_chars
          return succ(source.consume([excluding_length, 100000].min)) # max 100000 character atom, otherwise error in resulting regexp
        else
          return context.err(self, source, "No such string in input: #{@delimiters.inspect}.")
        end
      end

      def to_s_inner(prec)
        "until('#{@delimiters.inspect}')"
      end
    end

    class Parser < Parslet::Parser
      root(:template)

      # Text, tags and endings
      rule(:template)             { (text | ending | tag).repeat.as(:template) }
      rule(:text)                 { DelimitedChunk.new(['{{'], 1).as(:text) }
      rule(:ending)               { ltag >> str('end').as(:ending) >> rtag }
      rule(:tag)                  { ltag >> (operation >> rtag | tag_command | rtag) }

      # Command ending in rtag
      rule(:tag_command)          { tag_simple_command | (unary >> tag_command_tail).as(:chain) }
      rule(:tag_command_tail)     { dot >> (tag_simple_command.repeat(1,1) | simple_function >> tag_command_tail) }
      rule(:tag_simple_command)   { (name >> space >> tag_args).as(:call) }

      # Command ending in rparen
      rule(:paren_command)        { paren_simple_command | (unary >> paren_command_tail).as(:chain) }
      rule(:paren_command_tail)   { dot >> (paren_simple_command.repeat(1,1) | simple_function >> paren_command_tail) }
      rule(:paren_simple_command) { (name >> space >> paren_args).as(:call) }

      # Entry point to operations
      rule(:operation)            { logical_or }

      # Or / and
      rule(:logical_or)           { (logical_and >> ((pipe.as(:op) >> logical_and.as(:arg)).as(:or)).repeat(1)).as(:chain) | logical_and }
      rule(:logical_and)          { (equality >> ((ampersand.as(:op) >> equality.as(:arg)).as(:and)).repeat(1)).as(:chain) | equality }

      # Equality / inequality
      rule(:equality)             { (comparison >> (equals | differs).repeat(1)).as(:chain) | comparison }
      rule(:equals)               { (equals_sign.as(:op) >> comparison.as(:arg)).as(:equals) }
      rule(:differs)              { (bang_equals.as(:op) >> comparison.as(:arg)).as(:differs) }

      # Comparisons
      rule(:comparison)           { (additive >> (greater | less | greater_or_equal | less_or_equal).repeat(1)).as(:chain) | additive }
      rule(:greater)              { (rangle.as(:op) >> additive.as(:arg)).as(:greater) }
      rule(:less)                 { (langle.as(:op) >> additive.as(:arg)).as(:less) }
      rule(:greater_or_equal)     { (rangle_equals.as(:op) >> additive.as(:arg)).as(:greater_or_equal) }
      rule(:less_or_equal)        { (langle_equals.as(:op) >> additive.as(:arg)).as(:less_or_equal) }

      # Add / subtract
      rule(:additive)             { (multitive >> (add | subtract).repeat(1)).as(:chain) | multitive }
      rule(:add)                  { (plus.as(:op) >> multitive.as(:arg)).as(:add) }
      rule(:subtract)             { (dash.as(:op) >> multitive.as(:arg)).as(:subtract) }

      # Multiply / divide
      rule(:multitive)            { (function >> (multiply | divide | remainder).repeat(1)).as(:chain) | function }
      rule(:multiply)             { (asterisk.as(:op) >> function.as(:arg)).as(:multiply) }
      rule(:divide)               { (slash.as(:op) >> function.as(:arg)).as(:divide) }
      rule(:remainder)            { (percent.as(:op) >> function.as(:arg)).as(:remainder) }

      # Functions
      rule(:function)             { (unary >> (dot >> simple_function).repeat(1)).as(:chain) | unary }
      rule(:simple_function)      { (name >> lparen >> (rparen | paren_args)).as(:call) | (name >> space?).as(:call_or_variable) }

      # Unary operators
      rule(:unary)                { unary_operand | unary_negative | unary_not }
      rule(:unary_negative)       { (dash.as(:op) >> unary.as(:receiver)).as(:negative) }
      rule(:unary_not)            { (bang.as(:op) >> unary.as(:receiver)).as(:not) }

      # Unary operand
      rule(:unary_operand)        { value >> space? | parentheses | simple_function }
      rule(:parentheses)          { lparen >> (operation >> rparen | paren_command) }

      # Values
      rule(:value)                { str('true').as(:true) | str('false').as(:false) | empty_string | string | number }
      rule(:string)               { str("'") >> (str("\\") >> any | str("'").absent? >> any).repeat(1).as(:string) >> str("'") }
      rule(:empty_string)         { str("'") >> str('').as(:string) >> str("'") }
      rule(:number)               { match['0-9'].repeat(1).as(:number) }

      # Name and arguments
      rule(:name)                 { (match['a-z'] >> match['a-z0-9_'].repeat >> match['?!'].maybe).as(:name) }
      rule(:paren_args)           { (operation >> (comma >> operation).repeat >> rparen | paren_command).as(:args) }
      rule(:tag_args)             { (operation >> (comma >> operation).repeat >> rtag | tag_command).as(:args) }

      # Spaces
      rule(:space)                { match('\s').repeat(1) }
      rule(:space?)               { space.maybe }

      # Tag delimiters
      rule(:ltag)                 { str('{{') >> space? }
      rule(:rtag)                 { space? >> str('}}') }

      # Parens
      rule(:lparen)               { str('(')  >> space? }
      rule(:rparen)               { str(')')  >> space? }

      # Dot, comma
      rule(:comma)                { str(',')  >> space? }
      rule(:dot)                  { str('.') }

      # Operators
      rule(:pipe)                 { str('|')  >> space? }
      rule(:ampersand)            { str('&')  >> space? }
      rule(:equals_sign)          { str('=')  >> space? }
      rule(:bang_equals)          { str('!=') >> space? }
      rule(:langle)               { str('<')  >> space? }
      rule(:rangle)               { str('>')  >> space? }
      rule(:langle_equals)        { str('<=') >> space? }
      rule(:rangle_equals)        { str('>=') >> space? }
      rule(:plus)                 { str('+')  >> space? }
      rule(:dash)                 { str('-')  >> space? }
      rule(:asterisk)             { str('*')  >> space? }
      rule(:slash)                { str('/')  >> space? }
      rule(:percent)              { str('%')  >> space? }
      rule(:bang)                 { str('!')  >> space? }
    end
  end
end
