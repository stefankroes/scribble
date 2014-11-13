module Scribble
  class Method
    def initialize receiver, call, context
      @receiver, @call, @context = receiver, call, context
    end

    class << self
      attr_reader :method_name, :receiver_class, :signature

      # Setup instance variables

      def setup receiver_class, method_name, signature
        raise "Method name needs to be a Symbol, got #{method_name.inspect}" unless method_name.is_a?(Symbol)
        @receiver_class, @method_name, @signature = receiver_class, method_name, signature
      end

      # Insert method into a registry

      def eql? other
        receiver_class == other.receiver_class && method_name == other.method_name && signature == other.signature
      end

      def insert registry
        raise "Duplicate method #{method_name} on #{receiver_class}"            if registry.methods.any? { |method| eql? method }
        raise "Method #{method_name} must be a #{'non-' if split?}split method" unless [nil, split?].include? registry.split?(method_name)
        raise "Method #{method_name} must be a #{'non-' if block?}block method" unless [nil, block?].include? registry.block?(method_name)
        registry.methods << self
      end

      # Setup method and insert into default registry

      def register method_name, *signature, on: Template::Context
        setup  on, method_name, signature
        insert Registry.instance
      end

      # Subclass, setup and insert into registry

      def implement receiver_class, method_name, signature, registry, as: nil, to: nil, cast: nil, returns: nil, split: nil
        Class.new(self) do
          setup receiver_class, method_name, signature

          raise "Received multiple implementation options for method"     unless [as, to, cast, returns].compact.size <= 1
          raise "Method option :as requires String, got #{as.inspect}"    unless as.nil? || as.is_a?(String)
          raise "Method option :to requires Proc, got #{to.inspect}"      unless to.nil? || to.is_a?(Proc)
          raise "Method option :cast must be 'to_boolean' or 'to_string'" unless [nil, 'to_boolean', 'to_string'].include? cast
          raise "Method option :split must be true"                       unless [nil, true].include? split

          # Redefine split?
          define_singleton_method :split? do
            true
          end if split

          # Implement method
          send :define_method, method_name do |*args|
            if to
              @receiver.instance_exec *args, &to
            elsif cast
              registry.evaluate method_name, registry.send(cast, @receiver), args, @call, @context
            elsif !returns.nil?
              returns
            else
              @receiver.send (as || method_name), *args
            end
          end
        end.insert registry
      end

      # Default split and block

      def split?; false; end
      def block?; false; end

      # Arity

      def min_arity
        @min_arity ||= signature.reduce 0 do |min_arity, element|
          element.is_a?(Array) ? min_arity : min_arity + 1
        end
      end

      def max_arity
        @max_arity ||= signature.reduce 0 do |max_arity, element|
          if max_arity
            element.is_a?(Array) ? element[1] && max_arity + element[1] : max_arity + 1
          end
        end
      end
    end
  end
end
