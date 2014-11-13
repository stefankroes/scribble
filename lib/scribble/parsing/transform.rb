require 'parslet'

module Scribble
  module Parsing
    class Transform < Parslet::Transform

      # Template, text and endings

      rule template: sequence(:nodes) do
        Nester.new nodes
      end

      rule text: simple(:slice) do
        Nodes::Value.new slice, slice.to_s
      end

      rule ending: simple(:slice) do
        Nodes::Ending.new slice
      end

      # Binary operators

      %i(or and equals differs
         greater less greater_or_equal less_or_equal
         add subtract multiply divide remainder
      ).each do |operator|
        rule operator => {op: simple(:slice), arg: simple(:arg)} do
          Nodes::Call.new slice, operator, args: [arg]
        end
      end

      # Unary operators

      %i(negative not).each do |operator|
        rule operator => {op: simple(:slice), receiver: simple(:receiver)} do
          Nodes::Call.new slice, operator, receiver: receiver
        end
      end

      # Left associative operation reduction

      rule chain: sequence(:calls) do
        calls.reduce calls.shift do |base, call|
          call.receiver = base; call
        end
      end

      # Calls with no, one or multiple arguments

      rule call: {name: simple(:slice)} do
        Nodes::Call.new slice, slice.to_sym
      end

      rule call: {name: simple(:slice), args: simple(:arg)} do
        Nodes::Call.new slice, slice.to_sym, args: [arg]
      end

      rule call: {name: simple(:slice), args: sequence(:args)} do
        Nodes::Call.new slice, slice.to_sym, args: args
      end

      # Call without arguments or parentheses

      rule call_or_variable: {name: simple(:slice)} do
        Nodes::Call.new slice, slice.to_sym, allow_variable: true
      end

      # Values

      rule number: simple(:slice) do
        Nodes::Value.new slice, slice.to_i
      end

      rule string: simple(:slice) do
        Nodes::Value.new slice, slice.to_s.gsub(/\\(.)/, '\1')
      end

      rule true: simple(:slice) do
        Nodes::Value.new slice, true
      end

      rule false: simple(:slice) do
        Nodes::Value.new slice, false
      end
    end
  end
end
