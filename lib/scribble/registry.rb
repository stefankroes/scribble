module Scribble
  class Registry

    # Singleton

    def self.method_missing name, *args, &proc
      instance.send name, *args, &proc
    end

    def self.instance
      @instance ||= Registry.new
    end

    # For class context

    def for *classes, &proc
      classes.each { |receiver_class| ForClassContext.new(self, receiver_class).instance_eval &proc }
    end

    class ForClassContext < BasicObject
      def initialize registry, receiver_class
        @registry, @receiver_class = registry, receiver_class
      end

      def method name, *signature, block: false, **options
        (block ? Block : Method).implement @receiver_class, name, signature, @registry, **options
      end

      def to_boolean &proc
        method :to_boolean, to: proc
      end

      def to_string &proc
        method :to_string, to: proc
      end

      def name name
        @registry.class_name @receiver_class, name
      end
    end

    # Class names

    def class_names
      @class_names ||= {}
    end

    def class_name receiver_class, name = nil
      class_names[receiver_class] = name if name
      class_names[receiver_class] || receiver_class.name.downcase
    end

    # Methods

    def methods
      @methods ||= []
    end

    def unregister name
      methods.reject! { |method| method.name == name }
    end

    # Evaluate or cast

    def evaluate name, receiver, args, call = nil, context = nil
      matcher = Support::Matcher.new self, name, receiver, args
      matcher.match.new(receiver, call, context).send name, *args
    end

    def to_boolean receiver
      evaluate :to_boolean, receiver, []
    end

    def to_string receiver
      evaluate :to_string, receiver, []
    end

    # Split, block

    def split? name
      method_predicate name, :split?
    end

    def block? name
      method_predicate name, :block?
    end

  private

    def method_predicate name, predicate
      method = methods.find { |method| method.method_name == name }
      method && method.send(predicate)
    end
  end
end
